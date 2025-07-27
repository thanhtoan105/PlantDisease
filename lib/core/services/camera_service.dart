import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  static CameraController? _controller;
  static List<CameraDescription>? _cameras;
  static bool _isInitialized = false;

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

  /// Capture image and return file path
  static Future<String?> captureImage() async {
    if (!isInitialized) {
      debugPrint('Camera not initialized');
      return null;
    }

    try {
      final image = await _controller!.takePicture();

      // Process and save the image
      final processedImagePath = await _processImage(image.path);

      debugPrint('✅ Image captured: $processedImagePath');
      return processedImagePath;
    } catch (e) {
      debugPrint('❌ Failed to capture image: $e');
      return null;
    }
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
        width: 128,
        height: 128,
        interpolation: img.Interpolation.linear,
      );

      // Save processed image
      final directory = await getTemporaryDirectory();
      final processedImagePath =
          '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final processedFile = File(processedImagePath);
      await processedFile
          .writeAsBytes(img.encodeJpg(resizedImage, quality: 85));

      return processedImagePath;
    } catch (e) {
      debugPrint('❌ Image processing failed: $e');
      // Return original path if processing fails
      return imagePath;
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
