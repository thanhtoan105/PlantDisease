import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class LoadingSpinner extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const LoadingSpinner({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primaryGreen,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  final String? message;
  final Widget? child;

  const LoadingScreen({
    super.key,
    this.message,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: child ?? LoadingSpinner(message: message),
    );
  }
}
