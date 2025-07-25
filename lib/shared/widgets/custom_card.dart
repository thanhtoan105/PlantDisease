import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double padding;
  final EdgeInsets? margin;
  final Color backgroundColor;
  final double elevation;
  final double borderRadius;
  final Color? borderColor;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = AppDimensions.spacingLg,
    this.margin,
    this.backgroundColor = AppColors.white,
    this.elevation = AppDimensions.cardElevationMedium,
    this.borderRadius = AppDimensions.borderRadiusLarge,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      margin: margin,
      child: Material(
        color: backgroundColor,
        elevation: elevation,
        shadowColor: AppColors.cardShadow,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 1)
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
