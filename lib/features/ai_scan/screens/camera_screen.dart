import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/services/camera_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isCapturing = false;
  bool _isCameraSwitching = false;
  FlashMode _currentFlashMode = FlashMode.off;
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera({CameraDescription? cameraDescription}) async {
    setState(() {
      _isCameraSwitching = true;
    });
    try {
      // Get available cameras if not provided
      final cameras = CameraService.controller != null
          ? null
          : await availableCameras();
      final camera = cameraDescription ??
          (cameras != null && cameras.isNotEmpty
              ? cameras.firstWhere(
                  (c) => c.lensDirection == CameraLensDirection.back,
                  orElse: () => cameras.first,
                )
              : null);
      if (camera == null) {
        setState(() {
          _isCameraSwitching = false;
        });
        return;
      }
      final newController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await newController.initialize();
      _controller?.dispose();
      if (mounted) {
        setState(() {
          _controller = newController;
          _isCameraSwitching = false;
        });
      } else {
        newController.dispose();
      }
    } catch (e) {
      setState(() {
        _isCameraSwitching = false;
      });
    }
  }

  Future<void> _captureImage() async {
    if (_isCapturing || _controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final image = await _controller!.takePicture();
      if (image.path.isNotEmpty && mounted) {
        Navigator.of(context).pop(image.path);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture image')),
        );
      }
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

  Future<void> _toggleFlash() async {
    final newMode =
        _currentFlashMode == FlashMode.off ? FlashMode.always : FlashMode.off;

    await CameraService.setFlashMode(newMode);
    setState(() {
      _currentFlashMode = newMode;
    });
  }

  Future<void> _switchCamera() async {
    if (_isCameraSwitching || _controller == null) return;
    setState(() {
      _isCameraSwitching = true;
    });
    try {
      final cameras = await availableCameras();
      final current = _controller!.description;
      final newCamera = cameras.firstWhere(
        (c) => c.lensDirection != current.lensDirection,
        orElse: () => cameras.first,
      );
      await _initializeCamera(cameraDescription: newCamera);
    } catch (e) {
      setState(() {
        _isCameraSwitching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot switch camera')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        // Return the image path to the previous screen
        Navigator.of(context).pop(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Widget _buildModeButton(String label, bool isActive) {
    return Text(
      label,
      style: TextStyle(
        color: isActive ? Colors.white : Colors.grey,
        fontSize: 16,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_isCameraSwitching || controller == null || !controller.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview - full screen
          Positioned.fill(
            child: CameraPreview(controller),
          ),

          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button (X)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),

                  // Menu button (three lines)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Could open camera settings or options
                      },
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Camera mode controls (bottom section above controls)
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              color: Colors.black.withValues(alpha: 0.6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildModeButton('Photo', true),
                  _buildModeButton('Pro', false),
                  _buildModeButton('Portrait', false),
                  _buildModeButton('Video', false),
                  _buildModeButton('More', false),
                ],
              ),
            ),
          ),

          // Lighting control button (top-left, positioned lower)
          Positioned(
            top: 120,
            left: 20,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _toggleFlash,
                icon: Icon(
                  _currentFlashMode == FlashMode.off
                      ? Icons.flash_off
                      : Icons.flash_on,
                  color: Colors.white,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),

          // Bottom controls - redesigned to match the provided image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 120,
                color: Colors.black.withValues(alpha: 0.8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery picker button (left)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        onPressed: _pickFromGallery,
                        icon: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),

                    // Capture button (center) - red circular button
                    GestureDetector(
                      onTap: _isCapturing ? null : _captureImage,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isCapturing ? Colors.grey : Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: _isCapturing
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
                            : null, // No icon, just the red circle
                      ),
                    ),

                    // Camera switch button (right)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _switchCamera,
                        icon: const Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isCapturing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                    Text(
                      'Capturing...',
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
