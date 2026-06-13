import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';
import '../../../navigation/route_names.dart';

class PublicDemoScreen extends StatelessWidget {
  const PublicDemoScreen({super.key});

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
                                    onTryDemo: () =>
                                        _showWebInferencePreview(context),
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
                                  onTryDemo: () =>
                                      _showWebInferencePreview(context),
                                ),
                                const SizedBox(height: AppDimensions.spacingLg),
                                const _DemoStatusPanel(),
                              ],
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

  void _showWebInferencePreview(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Web inference preview is being prepared. The Android app keeps native TensorFlow Lite scanning.',
        ),
      ),
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
  const _HeroPanel({required this.onTryDemo});

  final VoidCallback onTryDemo;

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
                onPressed: onTryDemo,
                icon: const Icon(Icons.image_search),
                label: const Text('Try the web demo'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(RouteNames.main),
                icon: const Icon(Icons.login),
                label: const Text('Open full app'),
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
