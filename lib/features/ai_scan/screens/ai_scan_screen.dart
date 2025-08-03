import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/tensorflow_service.dart';
import '../../../core/services/weather_service.dart';

import 'results_screen.dart';
import 'crop_image_screen.dart';

class AiScanScreen extends StatefulWidget {
  const AiScanScreen({super.key});

  @override
  State<AiScanScreen> createState() => _AiScanScreenState();
}

class _AiScanScreenState extends State<AiScanScreen>
    with TickerProviderStateMixin {
  // Camera and permissions
  bool _cameraInitialized = false;
  bool _hasPermission = false;
  FlashMode _flashMode = FlashMode.off;

  // AI and analysis
  bool _tensorflowInitialized = false;
  bool _modelLoaded = false;
  bool _isAnalyzing = false;
  bool _isCapturing = false;
  String? _error;

  // Animations
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkCameraPermission();
    _initializeServices();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);

    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
    } else if (status.isDenied) {
      final result = await Permission.camera.request();
      setState(() {
        _hasPermission = result.isGranted;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    CameraService.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      // Debug asset availability first
      final assetResults = await TensorFlowService.debugAssetAvailability();
      debugPrint('🔍 Asset check results: $assetResults');

      // Initialize TensorFlow model
      final tensorflowInitialized = await TensorFlowService.initialize();
      final modelLoaded = TensorFlowService.isModelLoaded;
      final modelError = TensorFlowService.initializationError;

      // Initialize camera
      final cameraInitialized = await CameraService.initialize();

      if (mounted) {
        setState(() {
          _tensorflowInitialized = tensorflowInitialized;
          _modelLoaded = modelLoaded;
          _cameraInitialized = cameraInitialized;

          if (!tensorflowInitialized) {
            _error = 'Failed to initialize TensorFlow service';
          } else if (!cameraInitialized) {
            _error =
                'Camera not available. If using emulator, configure virtual cameras in AVD Manager.';
          } else if (!modelLoaded && modelError != null) {
            _error = null; // Clear error since we can still function
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Initialization failed: $e';
        });
      }
    }
  }

  /// Helper method to crop and process an image before analysis
  Future<void> _cropAndProcessImage(String imagePath) async {
    try {
      // Show the cropping interface
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Plant Image',
            toolbarColor: AppColors.primaryGreen,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: AppColors.primaryGreen,
            cropFrameColor: AppColors.primaryGreen,
            cropGridColor: Colors.white.withOpacity(0.5),
            dimmedLayerColor: Colors.black.withOpacity(0.6),
            statusBarColor: const Color(0xFF1B5E20),
            initAspectRatio: CropAspectRatioPreset.original,
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
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            hidesNavigationBar: false,
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
          ),
        ],
      );

      // If user canceled cropping
      if (croppedFile == null) {
        return;
      }

      // Process the cropped image
      final processedImagePath = await CameraService.processGalleryImage(croppedFile.path);

      if (mounted) {
        final locationResult = await WeatherService.getCurrentLocation();
        final locationData = locationResult['success'] == true
            ? locationResult['data']
            : null;
        await _analyzeImage(processedImagePath, locationData: locationData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image processing error: $e')),
        );
      }
    }
  }

  Future<void> _captureImage() async {
    if (!_tensorflowInitialized || !_cameraInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      // Add haptic feedback
      HapticFeedback.lightImpact();

      // Capture image from camera
      final imagePath = await CameraService.captureImage();
      if (imagePath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to capture image')),
          );
        }
        return;
      }

      // Use the common helper method for cropping and processing
      await _cropAndProcessImage(imagePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (!_tensorflowInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please wait for TensorFlow to initialize')),
        );
      }
      return;
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        // Use the common helper method for cropping and processing
        await _cropAndProcessImage(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (!_cameraInitialized) return;

    setState(() {
      _flashMode =
          _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    });

    await CameraService.setFlashMode(_flashMode);
    HapticFeedback.selectionClick();
  }

  Future<void> _analyzeImage(String imagePath,
      {Map<String, dynamic>? locationData}) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await TensorFlowService.analyzeImage(imagePath);

      if (mounted) {
        if (result['success']) {
          // Navigate to results screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                imagePath: imagePath,
                analysisResult: result['data'],
                locationData: locationData,
              ),
            ),
          );
        } else {
          // Check if this is a model file issue
          if (result['requiresModelFile'] == true) {
            _showModelFileDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Analysis failed: \\${result['error']}')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _showModelFileDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AI Model Required'),
          content: const Text(
            'The AI model file is missing. To use plant disease detection, please:\n\n'
            '1. Add the tomato_model_final.tflite file to assets/models/\n'
            '2. Restart the app\n\n'
            'The app can still be used for other features.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = CameraService.controller;

    // Show permission request screen if needed
    if (!_hasPermission) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt,
                size: 80,
                color: Colors.white54,
              ),
              const SizedBox(height: 24),
              const Text(
                'Camera Permission Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please grant camera permission to scan plants',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkCameraPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading screen while camera initializes
    if (!_cameraInitialized ||
        controller == null ||
        !controller.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 24),
              Text(
                'Initializing Camera...',
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen camera preview
          Positioned.fill(
            child: CameraPreview(controller),
          ),

          // Simple Header with Gradient Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Top Controls (Flash and Camera Switch)
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Flash toggle
                GestureDetector(
                  onTap: _toggleFlash,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _flashMode == FlashMode.torch
                          ? Icons.flash_on
                          : Icons.flash_off,
                      color: _flashMode == FlashMode.torch
                          ? Colors.yellow
                          : Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                // // Camera switch
                // GestureDetector(
                //   onTap: _switchCamera,
                //   child: Container(
                //     width: 50,
                //     height: 50,
                //     decoration: BoxDecoration(
                //       color: Colors.black.withValues(alpha: 0.5),
                //       shape: BoxShape.circle,
                //     ),
                //     child: const Icon(
                //       Icons.flip_camera_ios,
                //       color: Colors.white,
                //       size: 24,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Picture Tips Box
                GestureDetector(
                  onTap: () {
                    // Navigation to picture tips screen would go here
                    // Currently disabled/empty as requested
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Picture Tips coming soon')),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.photo_camera,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Picture Tips',
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                    top: 20,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery button
                      GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),

                      // Capture button (center) - large circular button
                      GestureDetector(
                        onTap: _tensorflowInitialized &&
                                _cameraInitialized &&
                                !_isAnalyzing &&
                                !_isCapturing
                            ? _captureImage
                            : null,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isCapturing ? 0.9 : 1.0,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: _tensorflowInitialized &&
                                          _cameraInitialized &&
                                          !_isAnalyzing &&
                                          !_isCapturing
                                      ? AppColors.primaryGreen
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryGreen
                                          .withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: _isCapturing || _isAnalyzing
                                    ? const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Placeholder to maintain spacing (replaced camera switcher)
                      const SizedBox(width: 60, height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay when analyzing
          if (_isAnalyzing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Analyzing Plant...',
                        style: AppTypography.headlineMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait while AI examines the image',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
