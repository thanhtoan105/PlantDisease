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
            // App Logo and Name (smaller)
            _buildAppHeader(),

            const SizedBox(height: AppDimensions.spacingLg),

            // App Description
            _buildAppDescription(),

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
          // App Icon (using app-icon.png, bigger)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
              child: Image.asset(
                'assets/app-icon.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'PlantCare',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Smart Plant Disease Detection',
            style: AppTypography.bodySmall.copyWith(
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
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                'About This App',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'PlantCare AI is an innovative application designed for plant disease detection and monitoring. '
            'Using advanced artificial intelligence and machine learning technology, the app helps farmers, '
            'gardeners, and plant enthusiasts identify diseases early and take appropriate action to protect their crops.',
            style: AppTypography.bodyMedium.copyWith(
              height: 1.5,
              color: AppColors.darkNavy,
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
