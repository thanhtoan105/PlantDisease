import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../widgets/profile_option_card.dart';
import '../../../navigation/route_names.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: CustomAppBar(
        title: 'Setting',
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Information
                _buildUserInformation(context, authProvider),

                const SizedBox(height: AppDimensions.spacingLg),

                // Combined Settings and App Info
                _buildCombinedOptions(context),

                const Spacer(),

                // Sign In/Logout Button
                _buildAuthButton(context, authProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInformation(
      BuildContext context, AuthProvider authProvider) {
    return CustomCard(
      child: Column(
        children: [
          // Avatar and basic info
          Row(
            children: [
              // Profile Avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: authProvider.isAuthenticated
                    ? AppColors.primaryGreen
                    : AppColors.mediumGray,
                child: Text(
                  authProvider.isAuthenticated
                      ? (authProvider.user?.email?.substring(0, 1).toUpperCase() ?? 'U')
                      : 'G',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),

              const SizedBox(width: AppDimensions.spacingLg),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.isAuthenticated
                          ? (authProvider.user?.email ?? 'User')
                          : 'Guest User',
                      style: AppTypography.headlineMedium,
                    ),
                    Text(
                      authProvider.isAuthenticated
                          ? (authProvider.user?.email ?? '')
                          : 'Sign in to save your scan results',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.mediumGray,
                      ),
                    ),
                    Text(
                      authProvider.isAuthenticated
                          ? 'Member since ${DateTime.now().year}'
                          : 'Limited features available',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          // Edit Profile Button
          if (authProvider.isAuthenticated)
            CustomButton(
              text: 'Edit Profile',
              onPressed: () {
                context.push(RouteNames.editProfile);
              },
              type: ButtonType.secondary,
            ),
        ],
      ),
    );
  }

  Widget _buildCombinedOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileOptionCard(
          icon: Icons.language,
          title: 'Language',
          subtitle: 'English',
          onTap: () {
            // TODO: Navigate to language settings
          },
        ),
        ProfileOptionCard(
          icon: Icons.dark_mode,
          title: 'Theme',
          subtitle: 'Light mode',
          onTap: () {
            // TODO: Navigate to theme settings
          },
        ),
        ProfileOptionCard(
          icon: Icons.info,
          title: 'About',
          subtitle: 'Learn more about this app',
          onTap: () {
            // TODO: Navigate to about screen
          },
        ),
        ProfileOptionCard(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () {
            // TODO: Navigate to help screen
          },
        ),
        ProfileOptionCard(
          icon: Icons.star,
          title: 'Rate App',
          subtitle: 'Rate us on the app store',
          onTap: () {
            // TODO: Open app store rating
          },
        ),
      ],
    );
  }

  Widget _buildAuthButton(BuildContext context, AuthProvider authProvider) {
    return CustomButton(
      text: authProvider.isAuthenticated ? 'Logout' : 'Sign In',
      onPressed: () async {
        if (authProvider.isAuthenticated) {
          // Show logout confirmation
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            await authProvider.signOut();
            await authProvider.resetOnboarding();
            if (context.mounted) {
              context.go(RouteNames.onboarding);
            }
          }
        } else {
          // Navigate to auth screen
          context.push(RouteNames.auth);
        }
      },
      type: ButtonType.secondary,
      icon: Icon(
        authProvider.isAuthenticated ? Icons.logout : Icons.login,
        color: authProvider.isAuthenticated
            ? AppColors.errorRed
            : AppColors.primaryGreen,
      ),
    );
  }
}
