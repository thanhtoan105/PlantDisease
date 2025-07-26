import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_card.dart';

class CropCard extends StatelessWidget {
  final String name;
  final String emoji;
  final int diseaseCount;
  final VoidCallback? onTap;

  const CropCard({
    super.key,
    required this.name,
    required this.emoji,
    required this.diseaseCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110, // Reduced from 120 to 110
      child: CustomCard(
        onTap: onTap,
        padding: AppDimensions.spacingSm, // Reduced from spacingMd to spacingSm
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji container - optimized size
            Container(
              width: 40, // Reduced from 50 to 40
              height: 40, // Reduced from 50 to 40
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusMedium), // Reduced radius
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 24), // Reduced from 28 to 24
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXs), // Reduced spacing

            // Crop name - optimized typography
            Flexible(
              child: Text(
                name,
                style: AppTypography.labelSmall.copyWith(
                  // Changed from labelMedium to labelSmall
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkNavy,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 4), // Reduced spacing

            // Disease count badge - more compact
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6, // Reduced padding
                vertical: 1, // Reduced padding
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSmall),
              ),
              child: Text(
                '$diseaseCount diseases',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                  fontSize: 9, // Reduced from 10 to 9
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
