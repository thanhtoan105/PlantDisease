import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../models/public_demo_upload_policy.dart';
import '../../../navigation/route_names.dart';

class PublicDemoImageSelection {
  const PublicDemoImageSelection({
    required this.fileName,
    required this.bytes,
  });

  final String fileName;
  final List<int> bytes;
}

class PublicDemoScreen extends StatefulWidget {
  const PublicDemoScreen({
    super.key,
    this.initialSelection,
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker;

  final PublicDemoImageSelection? initialSelection;
  final ImagePicker? _imagePicker;

  @override
  State<PublicDemoScreen> createState() => _PublicDemoScreenState();
}

class _PublicDemoScreenState extends State<PublicDemoScreen> {
  late final ImagePicker _imagePicker;
  final GlobalKey _uploadPanelKey = GlobalKey();
  PublicDemoImageSelection? _selection;
  String? _uploadError;

  @override
  void initState() {
    super.initState();
    _imagePicker = widget._imagePicker ?? ImagePicker();
    _selection = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 840;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide
                    ? AppDimensions.spacingXxxl
                    : AppDimensions.spacingLg,
                vertical: AppDimensions.spacingXl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(onOpenApp: () => context.go(RouteNames.main)),
                      SizedBox(
                        height: isWide
                            ? AppDimensions.spacingXxxl
                            : AppDimensions.spacingXl,
                      ),
                      isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: _HeroPanel(
                                    onPreviewUpload: _previewUploadFlow,
                                  ),
                                ),
                                const SizedBox(
                                    width: AppDimensions.spacingXxl),
                                const Expanded(
                                  flex: 4,
                                  child: _DemoStatusPanel(),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _HeroPanel(
                                  onPreviewUpload: _previewUploadFlow,
                                ),
                                const SizedBox(height: AppDimensions.spacingLg),
                                const _DemoStatusPanel(),
                              ],
                            ),
                      const SizedBox(height: AppDimensions.spacingXxl),
                      _UploadPanel(
                        key: _uploadPanelKey,
                        selection: _selection,
                        errorText: _uploadError,
                        onChooseImage: _chooseImage,
                        onRemoveImage: _removeImage,
                        onDetect: _selection == null ? null : _showDetectPreview,
                      ),
                      const SizedBox(height: AppDimensions.spacingXxl),
                      const _FeatureGrid(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _chooseImage() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null) {
      return;
    }

    final bytes = await pickedImage.readAsBytes();
    final validation = validatePublicDemoUpload(
      fileName: pickedImage.name,
      fileSizeBytes: bytes.length,
    );

    if (!validation.isValid) {
      setState(() {
        _selection = null;
        _uploadError = validation.message;
      });
      return;
    }

    setState(() {
      _selection = PublicDemoImageSelection(
        fileName: pickedImage.name,
        bytes: bytes,
      );
      _uploadError = null;
    });
  }

  void _removeImage() {
    setState(() {
      _selection = null;
      _uploadError = null;
    });
  }

  void _showDetectPreview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Inference will be wired in US-009. Image preview is ready.',
        ),
      ),
    );
  }

  void _previewUploadFlow() {
    final uploadContext = _uploadPanelKey.currentContext;
    if (uploadContext != null) {
      Scrollable.ensureVisible(
        uploadContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Choose a leaf image in the upload preview below. Native inference stays in the full app for now.',
        ),
      ),
    );
  }
}

class _UploadPanel extends StatelessWidget {
  const _UploadPanel({
    super.key,
    required this.selection,
    required this.errorText,
    required this.onChooseImage,
    required this.onRemoveImage,
    required this.onDetect,
  });

  final PublicDemoImageSelection? selection;
  final String? errorText;
  final VoidCallback onChooseImage;
  final VoidCallback onRemoveImage;
  final VoidCallback? onDetect;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selection != null;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upload a leaf image', style: AppTypography.headlineSmall),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'JPG, PNG, or WebP up to 5 MB.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          if (hasSelection)
            _SelectedImagePreview(
              selection: selection!,
              onRemoveImage: onRemoveImage,
            )
          else
            _EmptyUploadState(onChooseImage: onChooseImage),
          if (errorText != null) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              errorText!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.spacingLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onDetect,
              icon: const Icon(Icons.search),
              label: const Text('Detect Disease'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyUploadState extends StatelessWidget {
  const _EmptyUploadState({required this.onChooseImage});

  final VoidCallback onChooseImage;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChooseImage,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.24),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.add_photo_alternate,
              color: AppColors.primaryGreen,
              size: 36,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              'Click to choose a leaf image',
              textAlign: TextAlign.center,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              'Use a clear, well-lit JPG, PNG, or WebP photo.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedImagePreview extends StatelessWidget {
  const _SelectedImagePreview({
    required this.selection,
    required this.onRemoveImage,
  });

  final PublicDemoImageSelection selection;
  final VoidCallback onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.memory(
              Uint8List.fromList(selection.bytes),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.primaryGreen),
            const SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: Text(selection.fileName, style: AppTypography.labelLarge),
            ),
            TextButton.icon(
              onPressed: onRemoveImage,
              icon: const Icon(Icons.close),
              label: const Text('Remove image'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onOpenApp});

  final VoidCallback onOpenApp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          ),
          child: const Icon(
            Icons.eco,
            color: AppColors.white,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: Text(
            'Plant AI Disease Detection',
            style: AppTypography.headlineMedium,
          ),
        ),
        TextButton(
          onPressed: onOpenApp,
          child: const Text('Open full app'),
        ),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.onPreviewUpload});

  final VoidCallback onPreviewUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI-assisted plant health checks for farmers and gardeners.',
            style: AppTypography.headlineLarge.copyWith(fontSize: 30),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            'Upload or capture plant images, review disease signals, and get care guidance. This web portfolio shell is public; authenticated history and native camera scanning remain in the full app.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.mediumGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXl),
          Wrap(
            spacing: AppDimensions.spacingMd,
            runSpacing: AppDimensions.spacingMd,
            children: [
              ElevatedButton.icon(
                onPressed: onPreviewUpload,
                icon: const Icon(Icons.image_search),
                label: const Text('Preview upload flow'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(RouteNames.main),
                icon: const Icon(Icons.login),
                label: const Text('Open authenticated app'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoStatusPanel extends StatelessWidget {
  const _DemoStatusPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.science,
            color: AppColors.primaryGreen,
            size: 36,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            'Web inference preview',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'The web build is live-ready. Browser inference is intentionally separated from Android TensorFlow Lite and will be wired in a follow-up story.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mediumGray,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    const features = [
      _FeatureItem(
        icon: Icons.local_florist,
        title: 'Durian disease model',
        description: 'Current labels cover six durian leaf health classes.',
      ),
      _FeatureItem(
        icon: Icons.cloud,
        title: 'Weather context',
        description: 'Care recommendations can include local weather signals.',
      ),
      _FeatureItem(
        icon: Icons.history,
        title: 'Scan history',
        description: 'Authenticated users can keep prior scan results.',
      ),
    ];

    return Wrap(
      spacing: AppDimensions.spacingLg,
      runSpacing: AppDimensions.spacingLg,
      children: features
          .map(
            (feature) => SizedBox(
              width: 330,
              child: feature,
            ),
          )
          .toList(),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
