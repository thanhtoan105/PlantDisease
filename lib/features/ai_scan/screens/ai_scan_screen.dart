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
import '../../../shared/utils/custom_dialogs.dart';

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
    _flashMode = FlashMode.off; // Always reset flash to OFF when entering this screen
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
            cropGridColor: Colors.white.withValues(alpha: 0.5),
            dimmedLayerColor: Colors.black.withValues(alpha: 0.6),
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

      // If user canceled cropping, reset flash and return
      if (croppedFile == null) {
        if (mounted) setState(() => _flashMode = FlashMode.off);
        return;
      }

      // Process the cropped image
      final processedImagePath = await CameraService.processGalleryImage(croppedFile.path);

      if (mounted) {
        debugPrint('\n📍 Getting location data...');
        final locationResult = await WeatherService.getCurrentLocation();

        debugPrint('📍 Location service response:');
        debugPrint('  Type: ${locationResult.runtimeType}');
        debugPrint('  Keys: ${locationResult.keys.toList()}');
        debugPrint('  Full result: $locationResult');
        debugPrint('  success: ${locationResult['success']}');

        if (locationResult['data'] != null) {
          debugPrint('  data type: ${locationResult['data'].runtimeType}');
          debugPrint('  data value: ${locationResult['data']}');
          debugPrint('  data is String? ${locationResult['data'] is String}');
          debugPrint('  data is Map? ${locationResult['data'] is Map}');
        }

        // Extract location data with defensive type checking
        String? locationData;
        Map<String, dynamic>? weatherData;

        if (locationResult['success'] == true && locationResult['data'] != null) {
          final data = locationResult['data'];
          debugPrint('\n📍 Extracting location data:');
          debugPrint('  Input type: ${data.runtimeType}');

          // Handle both String and Map types defensively
          if (data is String) {
            locationData = data;
            debugPrint('  ✅ Is String, using directly: "$locationData"');
          } else if (data is Map) {
            // Fallback: if somehow a Map is returned, convert it to a readable string
            locationData = data.toString();
            debugPrint('  ⚠️⚠️⚠️ WARNING: locationData was a Map!');
            debugPrint('  Map keys: ${data.keys.toList()}');
            debugPrint('  Converted to String: "$locationData"');
          } else {
            locationData = 'Unknown Location';
            debugPrint('  ❌ WARNING: Unexpected type ${data.runtimeType}');
            debugPrint('  Using fallback: "$locationData"');
          }

          // Fetch weather data if we have coordinates
          if (locationResult['latitude'] != null && locationResult['longitude'] != null) {
            debugPrint('\n🌤️ Fetching weather data...');
            final weatherResult = await WeatherService.getCurrentWeather(
              locationResult['latitude'],
              locationResult['longitude'],
            );

            if (weatherResult['success'] == true && weatherResult['data'] != null) {
              weatherData = weatherResult['data'] as Map<String, dynamic>?;
              debugPrint('✅ Weather data fetched successfully');
            } else {
              debugPrint('⚠️ Weather fetch failed: ${weatherResult['error']}');
            }
          }
        } else {
          debugPrint('  ⚠️ Location fetch failed or data is null');
          locationData = null;
        }

        debugPrint('\n📍 Final locationData before analysis:');
        debugPrint('  Type: ${locationData.runtimeType}');
        debugPrint('  Value: "$locationData"');
        debugPrint('  Is String? ${locationData is String}');
        debugPrint('  Is Map? ${locationData is Map}\n');

        await _analyzeImage(processedImagePath, locationData: locationData, weatherData: weatherData);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _flashMode = FlashMode.off); // Reset flash on error too
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
      {String? locationData, Map<String, dynamic>? weatherData}) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      debugPrint('\n🔬 _analyzeImage called:');
      debugPrint('  imagePath: $imagePath');
      debugPrint('  locationData type: ${locationData.runtimeType}');
      debugPrint('  locationData value: $locationData');
      debugPrint('  locationData is String? ${locationData is String}');
      debugPrint('  weatherData: ${weatherData != null ? "Available" : "Not available"}');
      debugPrint('  locationData is Map? ${locationData is Map}');

      final result = await TensorFlowService.analyzeImage(imagePath);

      debugPrint('\n📊 TensorFlow analysis result:');
      debugPrint('  success: ${result['success']}');
      if (result['success']) {
        debugPrint('  data type: ${result['data'].runtimeType}');
        debugPrint('  data keys: ${result['data'].keys.toList()}');
      }

      if (mounted) {
        if (result['success']) {
          debugPrint('\n🚀 Navigating to ResultsScreen with:');
          debugPrint('  imagePath type: ${imagePath.runtimeType}');
          debugPrint('  analysisResult type: ${result['data'].runtimeType}');
          debugPrint('  locationData type: ${locationData.runtimeType}');
          debugPrint('  locationData value: "$locationData"');
          debugPrint('  locationData is String? ${locationData is String}');
          debugPrint('  locationData is Map? ${locationData is Map}\n');

          try {
            // Explicitly type-check locationData before navigation
            final String? typedLocationData = locationData;
            debugPrint('🚨 Type-checked locationData:');
            debugPrint('   Type: ${typedLocationData.runtimeType}');
            debugPrint('   Value: "$typedLocationData"');
            debugPrint('   Is String?: ${typedLocationData is String?}');
            debugPrint('   weatherData available: ${weatherData != null}');

            // Navigate to results screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  debugPrint('🏗️ Building ResultsScreen widget...');
                  return ResultsScreen(
                    imagePath: imagePath,
                    analysisResult: result['data'],
                    locationData: typedLocationData,
                    weatherData: weatherData,
                  );
                },
              ),
            );
          } catch (navError, navStack) {
            debugPrint('❌❌❌ Navigation Error: $navError');
            debugPrint('Stack: $navStack');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigation error: $navError')),
            );
          }
        } else {
          // Check if this is a model file issue
          if (result['requiresModelFile'] == true) {
            _showModelFileDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Analysis failed: ${result['error']}')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error in _analyzeImage: $e');
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
    CustomDialogs.showInfoDialog(
      context: context,
      title: 'AI Model Required',
      message: 'The AI model file is missing. To use plant disease detection, please:\n\n'
          '1. Add the model.tflite file to assets/models/\n'
          '2. Restart the app\n\n'
          'The app can still be used for other features.',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: ElevatedButton(
                  onPressed: _checkCameraPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Grant Permission'),
                ),
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

          // Top Controls (Back Button, Flash and Camera Switch)
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          // Flash Control
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
