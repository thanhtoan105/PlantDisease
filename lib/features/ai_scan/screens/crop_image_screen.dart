import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class CropImageScreen extends StatefulWidget {
  final String imagePath;

  const CropImageScreen({super.key, required this.imagePath});

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  late File _imageFile;
  bool _isCropping = false;

  @override
  void initState() {
    super.initState();
    _imageFile = File(widget.imagePath);
  }

  Future<void> _cropImage() async {
    setState(() {
      _isCropping = true;
    });

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.imagePath,
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
            cropGridColor: Colors.white.withValues(alpha: 128), // Using withValues instead of withOpacity
            dimmedLayerColor: Colors.black.withValues(alpha: 153), // Using withValues instead of withOpacity
            statusBarColor: const Color(0xFF1B5E20), // Using a direct color value instead of shade900
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

      if (croppedFile != null) {
        // Return the path of the cropped file to the previous screen
        Navigator.pop(context, croppedFile.path);
      } else {
        // User canceled the cropping
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to crop image: $e')),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() {
          _isCropping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        title: 'Crop Image',
        onLeadingPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _cropImage,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Image display
            Positioned.fill(
              child: InteractiveViewer(
                child: Center(
                  child: Image.file(
                    _imageFile,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Cropping overlay will be provided by the image_cropper package

            // Loading indicator when cropping
            if (_isCropping)
              Container(
                color: Colors.black.withValues(alpha: 128),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
