import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/tensorflow_service.dart';
import '../../../shared/widgets/custom_button.dart';
import 'camera_screen.dart';
import 'results_screen.dart';

class AiScanScreen extends StatefulWidget {
  const AiScanScreen({super.key});

  @override
  State<AiScanScreen> createState() => _AiScanScreenState();
}

class _AiScanScreenState extends State<AiScanScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _modelLoaded = false;
  bool _cameraInitialized = false;
  bool _isAnalyzing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
    _initializeServices();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize TensorFlow model
      final modelLoaded = await TensorFlowService.initialize();

      // Initialize camera
      final cameraInitialized = await CameraService.initialize();

      if (mounted) {
        setState(() {
          _modelLoaded = modelLoaded;
          _cameraInitialized = cameraInitialized;
          if (!modelLoaded) {
            _error = 'Failed to load AI model';
          } else if (!cameraInitialized) {
            _error = 'Failed to initialize camera';
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

  Future<void> _openCamera() async {
    if (!_modelLoaded || !_cameraInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please wait for initialization to complete')),
      );
      return;
    }

    // Navigate to camera screen
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    );

    if (result != null) {
      await _analyzeImage(result);
    }
  }

  Future<void> _pickFromGallery() async {
    if (!_modelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for AI model to load')),
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _analyzeImage(pickedFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _analyzeImage(String imagePath) async {
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
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Analysis failed: ${result['error']}')),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Column(
          children: [
            // Modern Header with Status
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                child: Column(
                  children: [
                    Text(
                      'Plant Health Scanner',
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    _modelLoaded ? Colors.green : Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingSm),
                            Text(
                              _modelLoaded ? 'AI Ready' : 'Loading AI...',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _cameraInitialized
                                    ? Colors.green
                                    : Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingSm),
                            Text(
                              _cameraInitialized
                                  ? 'Camera Ready'
                                  : 'Loading Camera...',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Camera Preview Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(AppDimensions.spacingLg),
                decoration: BoxDecoration(
                  color: AppColors.mediumGray.withOpacity(0.3),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusLarge),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Camera preview or placeholder
                    if (_cameraInitialized && CameraService.controller != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusLarge),
                        child: CameraPreview(CameraService.controller!),
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 80,
                              color: AppColors.white.withOpacity(0.5),
                            ),
                            const SizedBox(height: AppDimensions.spacingLg),
                            Text(
                              _error ?? 'Initializing Camera...',
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.white.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppDimensions.spacingSm),
                            Text(
                              'Position the plant leaf within the frame',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.white.withOpacity(0.5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                    // Scanning frame overlay
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primaryGreen,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusLarge),
                        ),
                        child: Stack(
                          children: [
                            // Corner indicators
                            ...List.generate(4, (index) {
                              return Positioned(
                                top: index < 2 ? 0 : null,
                                bottom: index >= 2 ? 0 : null,
                                left: index % 2 == 0 ? 0 : null,
                                right: index % 2 == 1 ? 0 : null,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    borderRadius: BorderRadius.only(
                                      topLeft: index == 0
                                          ? const Radius.circular(8)
                                          : Radius.zero,
                                      topRight: index == 1
                                          ? const Radius.circular(8)
                                          : Radius.zero,
                                      bottomLeft: index == 2
                                          ? const Radius.circular(8)
                                          : Radius.zero,
                                      bottomRight: index == 3
                                          ? const Radius.circular(8)
                                          : Radius.zero,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    // Loading overlay
                    if (_isAnalyzing)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.darkNavy.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusLarge),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.primaryGreen,
                              ),
                              SizedBox(height: AppDimensions.spacingLg),
                              Text(
                                'Analyzing Image...',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Control buttons
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: Column(
                children: [
                  // Capture button
                  GestureDetector(
                    onTap: _modelLoaded && !_isAnalyzing ? _openCamera : null,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _modelLoaded && !_isAnalyzing
                            ? AppColors.primaryGreen
                            : AppColors.mediumGray,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 4,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppColors.white,
                        size: 32,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingLg),

                  // Gallery button
                  CustomButton(
                    text: 'Choose from Gallery',
                    onPressed:
                        _modelLoaded && !_isAnalyzing ? _pickFromGallery : null,
                    type: ButtonType.secondary,
                    disabled: !_modelLoaded || _isAnalyzing,
                  ),

                  const SizedBox(height: AppDimensions.spacingSm),

                  // Instructions
                  Text(
                    _modelLoaded
                        ? 'Tap the camera button to capture or choose from gallery'
                        : 'Please wait for AI model to load...',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.white.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
