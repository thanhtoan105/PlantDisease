import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_dimensions.dart';

class CustomSearchBar extends StatelessWidget {
  final String placeholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool enabled;

  const CustomSearchBar({
    super.key,
    this.placeholder = 'Search...',
    this.controller,
    this.onChanged,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingLg,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Text(
                  placeholder,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.mediumGray,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.secondary,
            size: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingLg,
          ),
        ),
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.darkNavy,
        ),
      ),
    );
  }
}
