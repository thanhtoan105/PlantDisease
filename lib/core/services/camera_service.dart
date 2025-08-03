import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';
import 'package:image_cropper/image_cropper.dart';

class CameraService {
  static CameraController? _controller;
  static List<CameraDescription>? _cameras;
  static bool _isInitialized = false;

  // Configuration constants
  /// The model input image size (width and height in pixels)
  /// Change this single value to update the processing size throughout the app
  static const int MODEL_INPUT_SIZE = 128;

  /// Image quality for JPEG compression (0-100)
  static const int IMAGE_QUALITY = 85;

  // 🎯 FEATURE TOGGLE: Comment this line to disable gallery saving
  static const bool _enableGallerySaving = true;

  /// Initialize camera service
  static Future<bool> initialize() async {
    try {
      // Request camera permission
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        debugPrint('Camera permission denied');
        return false;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('❌ No cameras available on this device');
        debugPrint(
            '💡 If running on emulator, configure virtual cameras in AVD Manager');
        debugPrint(
            '💡 On real devices, ensure camera hardware is working properly');
        return false;
      }

      // Initialize controller with back camera
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset
            .medium, // Use medium instead of high to reduce buffer usage
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;

      debugPrint('✅ Camera service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Camera initialization failed: $e');
      return false;
    }
  }

  /// Get camera controller
  static CameraController? get controller => _controller;

  /// Check if camera is initialized
  static bool get isInitialized => _isInitialized && _controller != null;

  /// Capture image and return file path (without cropping in service)
  static Future<String?> captureImage() async {
    if (!isInitialized) {
      debugPrint('Camera not initialized');
      return null;
    }

    try {
      final image = await _controller!.takePicture();
      debugPrint('✅ Image captured: ${image.path}');
      return image.path; // Return original path, let UI handle cropping
    } catch (e) {
      debugPrint('❌ Failed to capture image: $e');
      return null;
    }
  }

  /// Crop image with proper context (called from UI)
  static Future<String?> cropImage(String imagePath) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Plant Image',
            toolbarColor: const Color(0xFF2E7D32),
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: const Color(0xFF4CAF50),
            cropFrameColor: const Color(0xFF4CAF50),
            cropGridColor: const Color(0xFF81C784),
            dimmedLayerColor: Colors.black.withOpacity(0.6),
            statusBarColor: const Color(0xFF1B5E20),
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
          IOSUiSettings(
            title: 'Crop Plant Image',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            aspectRatioPickerButtonHidden: false,
            resetButtonHidden: false,
            rotateClockwiseButtonHidden: false,
            hidesNavigationBar: false,
          ),
        ],
      );

      if (croppedFile != null) {
        debugPrint('✅ Image cropped successfully: ${croppedFile.path}');
        return croppedFile.path;
      } else {
        debugPrint('❌ Image cropping cancelled by user');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Failed to crop image: $e');
      return null;
    }
  }

  /// Process gallery image for AI analysis (public method)
  static Future<String> processGalleryImage(String imagePath) async {
    return await _processImage(imagePath);
  }

  /// Process captured image for AI analysis
  static Future<String> _processImage(String imagePath) async {
    try {
      // Read the image
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image to model input size (matching React Native: 128x128)
      final resizedImage = img.copyResize(
        originalImage,
        width: MODEL_INPUT_SIZE,
        height: MODEL_INPUT_SIZE,
        interpolation: img.Interpolation.linear,
      );

      // Save processed image
      final directory = await getTemporaryDirectory();
      final processedImagePath =
          '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final processedFile = File(processedImagePath);
      await processedFile
          .writeAsBytes(img.encodeJpg(resizedImage, quality: IMAGE_QUALITY));

      // Save to gallery if enabled
      if (_enableGallerySaving) {
        await _saveImageToGallery(processedFile);
      }

      return processedImagePath;
    } catch (e) {
      debugPrint('❌ Image processing failed: $e');
      // Return original path if processing fails
      return imagePath;
    }
  }

  /// Save image to device gallery
  static Future<void> _saveImageToGallery(File imageFile) async {
    try {
      // Request storage permission first
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        debugPrint('❌ Storage permission denied for gallery save');
        return;
      }

      await Gal.putImage(imageFile.path, album: 'PlantAI');
      debugPrint('✅ Image saved to gallery: ${imageFile.path}');
    } catch (e) {
      debugPrint('❌ Failed to save image to gallery: $e');
    }
  }

  /// Switch camera (front/back)
  static Future<bool> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      return false;
    }

    try {
      final currentCamera = _controller!.description;
      final newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection != currentCamera.lensDirection,
      );

      await _controller!.dispose();

      _controller = CameraController(
        newCamera,
        ResolutionPreset.medium, // Consistent with initialization
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      return true;
    } catch (e) {
      debugPrint('❌ Failed to switch camera: $e');
      return false;
    }
  }

  /// Set flash mode
  static Future<void> setFlashMode(FlashMode mode) async {
    if (isInitialized) {
      await _controller!.setFlashMode(mode);
    }
  }

  /// Dispose camera resources
  static Future<void> dispose() async {
    try {
      if (_controller != null) {
        // Stop image stream if running
        if (_controller!.value.isStreamingImages) {
          await _controller!.stopImageStream();
        }

        // Dispose controller
        await _controller!.dispose();
        _controller = null;
        _isInitialized = false;
        debugPrint('✅ Camera resources disposed');
      }
    } catch (e) {
      debugPrint('❌ Error disposing camera: $e');
    }
  }

  /// Get available flash modes
  static List<FlashMode> get availableFlashModes {
    if (!isInitialized) return [];

    return [
      FlashMode.off,
      FlashMode.auto,
      FlashMode.always,
      FlashMode.torch,
    ];
  }

  /// Check if flash is available
  static bool get hasFlash {
    return isInitialized && _controller!.value.isInitialized;
  }

  /// Get current flash mode
  static FlashMode get currentFlashMode {
    return isInitialized ? _controller!.value.flashMode : FlashMode.off;
  }
}
