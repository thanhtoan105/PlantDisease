import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: CustomAppBar(
        title: 'About',
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Name
            _buildAppHeader(),

            const SizedBox(height: AppDimensions.spacingXl),

            // App Description
            _buildAppDescription(),

            const SizedBox(height: AppDimensions.spacingLg),

            // Features Section
            _buildFeaturesSection(),

            const SizedBox(height: AppDimensions.spacingLg),

            // App Version
            _buildVersionInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Center(
      child: Column(
        children: [
          // App Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXlarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.eco,
              size: 60,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            'PlantCare AI',
            style: AppTypography.headlineLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Smart Plant Disease Detection',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppDescription() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingSm),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                'About This App',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            'PlantCare AI is an innovative application designed for plant disease detection and monitoring. '
            'Using advanced artificial intelligence and machine learning technology, the app helps farmers, '
            'gardeners, and plant enthusiasts identify diseases early and take appropriate action to protect their crops.',
            style: AppTypography.bodyMedium.copyWith(
              height: 1.6,
              color: AppColors.darkNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingSm),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                ),
                child: const Icon(
                  Icons.stars,
                  color: AppColors.successGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                'Key Features',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          _buildFeatureItem(
            icon: Icons.camera_alt,
            title: 'AI-Powered Detection',
            description: 'Instantly identify plant diseases using your camera',
          ),
          _buildFeatureItem(
            icon: Icons.history,
            title: 'Scan History',
            description: 'Track and review your previous scans',
          ),
          _buildFeatureItem(
            icon: Icons.book,
            title: 'Disease Database',
            description: 'Comprehensive information about various plant diseases',
          ),
          _buildFeatureItem(
            icon: Icons.medical_services,
            title: 'Treatment Guidance',
            description: 'Get recommended treatments and prevention tips',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : AppDimensions.spacingMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info,
                color: AppColors.mediumGray,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                'Version',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
          Text(
            '1.0.0',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.darkNavy,
            ),
          ),
        ],
      ),
    );
  }
}
