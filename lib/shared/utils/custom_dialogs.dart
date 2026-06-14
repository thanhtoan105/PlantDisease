import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class CustomDialogs {
  /// Show a general information/alert dialog
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primaryGreen,
          ),
        ),
        content: Text(message, style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.pop(context),
            child: Text(
              buttonText,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show a "Coming Soon" dialog for features under development
  static Future<void> showComingSoonDialog({
    required BuildContext context,
    required String feature,
  }) {
    return showInfoDialog(
      context: context,
      title: 'Coming Soon',
      message: '$feature feature is coming soon! Stay tuned for updates.',
    );
  }

  /// Show an error dialog
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String error,
    String title = 'Error',
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTypography.headlineMedium.copyWith(color: Colors.red),
        ),
        content: Text(error, style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show a success dialog
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primaryGreen,
          ),
        ),
        content: Text(message, style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.pop(context),
            child: Text(
              buttonText,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show a confirmation dialog with Yes/No options
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primaryGreen,
          ),
        ),
        content: Text(message, style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmText,
              style: AppTypography.bodyMedium.copyWith(
                color: confirmColor ?? AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show a loading dialog (non-dismissible)
  static void showLoadingDialog({
    required BuildContext context,
    String message = 'Loading...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(message, style: AppTypography.bodyMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show a dialog with custom actions
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    required List<Widget> actions,
    Color? titleColor,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTypography.headlineMedium.copyWith(
            color: titleColor ?? AppColors.primaryGreen,
          ),
        ),
        content: Text(message, style: AppTypography.bodyMedium),
        actions: actions,
      ),
    );
  }
}
