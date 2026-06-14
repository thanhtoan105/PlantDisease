import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/utils/custom_snackbars.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: CustomAppBar(
        title: 'Help & Support',
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Us Section
            _buildContactSection(context),

            const SizedBox(height: AppDimensions.spacingLg),

            // Feedback Section
            _buildFeedbackSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingSm),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                ),
                child: const Icon(
                  Icons.contact_mail,
                  color: AppColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                'Contact Us',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // Email Contact
          _buildContactItem(
            context: context,
            icon: Icons.email,
            title: 'Email Support',
            subtitle: 'support@plantcare-ai.com',
            description: 'Get help via email',
            onTap: () => _launchEmail(context),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          // Phone Contact
          _buildContactItem(
            context: context,
            icon: Icons.phone,
            title: 'Phone Support',
            subtitle: '+84 123 456 789',
            description: 'Call us for immediate assistance',
            onTap: () => _launchPhone(context),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(color: AppColors.mediumGray.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryGreen,
                size: 24,
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
                    subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.mediumGray,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingSm),
                decoration: BoxDecoration(
                  color: AppColors.warningOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                ),
                child: const Icon(
                  Icons.feedback,
                  color: AppColors.warningOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                'Send Feedback',
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            'We value your feedback! Help us improve PlantCare AI by sharing your thoughts, suggestions, or reporting any issues you encounter.',
            style: AppTypography.bodyMedium.copyWith(
              height: 1.6,
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                CustomSnackbars.showInfo(
                  context: context,
                  message: 'This function is coming soon',
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Write Feedback'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacingLg,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@plantcare-ai.com',
      query: 'subject=PlantCare AI Support Request',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          CustomSnackbars.showInfo(
            context: context,
            message: 'Email: support@plantcare-ai.com',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbars.showError(
          context: context,
          message: 'Could not open email client',
        );
      }
    }
  }

  void _launchPhone(BuildContext context) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+84123456789',
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (context.mounted) {
          CustomSnackbars.showInfo(
            context: context,
            message: 'Phone: +84 123 456 789',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbars.showError(
          context: context,
          message: 'Could not open phone dialer',
        );
      }
    }
  }
}
