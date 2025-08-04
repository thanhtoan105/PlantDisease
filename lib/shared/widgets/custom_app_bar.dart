import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// A custom AppBar component that maintains consistent styling across the app.
///
/// This AppBar has a green background with white text and optional action buttons.
/// The title is centered by default.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onLeadingPressed;
  final bool automaticallyImplyLeading;
  final double elevation;
  final SystemUiOverlayStyle? systemOverlayStyle;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.leading,
    this.onLeadingPressed,
    this.automaticallyImplyLeading = true,
    this.elevation = 0,
    this.systemOverlayStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryGreen,
      elevation: elevation,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: AppTypography.headlineMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      automaticallyImplyLeading: automaticallyImplyLeading,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: _buildLeading(context),
      actions: actions,
      systemOverlayStyle: systemOverlayStyle ?? const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) {
      return leading;
    } else if (onLeadingPressed != null) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onLeadingPressed,
      );
    }
    return null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
