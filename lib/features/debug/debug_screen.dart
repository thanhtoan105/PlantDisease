import 'package:flutter/material.dart';
import '../../core/config/env_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_dimensions.dart';
import '../../shared/widgets/custom_card.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Debug Configuration'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Environment Configuration',
              style: AppTypography.headlineLarge,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            _buildConfigCard(
              'Environment Status',
              EnvConfig.isInitialized ? 'Initialized ✅' : 'Not Initialized ❌',
              EnvConfig.isInitialized
                  ? AppColors.successGreen
                  : AppColors.errorRed,
            ),
            _buildConfigCard(
              'Weather API Key',
              EnvConfig.weatherApiKey.isNotEmpty
                  ? 'Set ✅ (${EnvConfig.weatherApiKey.substring(0, 8)}...)'
                  : 'Missing ❌',
              EnvConfig.weatherApiKey.isNotEmpty
                  ? AppColors.successGreen
                  : AppColors.errorRed,
            ),
            _buildConfigCard(
              'Weather API Base URL',
              EnvConfig.weatherApiBaseUrl.isNotEmpty
                  ? 'Set ✅ (${EnvConfig.weatherApiBaseUrl})'
                  : 'Missing ❌',
              EnvConfig.weatherApiBaseUrl.isNotEmpty
                  ? AppColors.successGreen
                  : AppColors.errorRed,
            ),
            _buildConfigCard(
              'Supabase URL',
              EnvConfig.supabaseUrl.isNotEmpty
                  ? 'Set ✅ (${EnvConfig.supabaseUrl})'
                  : 'Missing ❌',
              EnvConfig.supabaseUrl.isNotEmpty
                  ? AppColors.successGreen
                  : AppColors.errorRed,
            ),
            _buildConfigCard(
              'Supabase Anon Key',
              EnvConfig.supabaseAnonKey.isNotEmpty
                  ? 'Set ✅ (${EnvConfig.supabaseAnonKey.substring(0, 20)}...)'
                  : 'Missing ❌',
              EnvConfig.supabaseAnonKey.isNotEmpty
                  ? AppColors.successGreen
                  : AppColors.errorRed,
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuration Validation',
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  ElevatedButton(
                    onPressed: () {
                      final isValid = EnvConfig.validateConfig();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isValid
                                ? 'All environment variables are properly configured!'
                                : 'Some environment variables are missing or invalid.',
                          ),
                          backgroundColor: isValid
                              ? AppColors.successGreen
                              : AppColors.errorRed,
                        ),
                      );
                    },
                    child: const Text('Validate Configuration'),
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  ElevatedButton(
                    onPressed: () {
                      EnvConfig.printConfigStatus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Configuration status printed to console'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                    child: const Text('Print Status to Console'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions',
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  Text(
                    '1. Make sure your .env file is in the project root\n'
                    '2. Verify all required variables are set\n'
                    '3. Restart the app after changing .env file\n'
                    '4. Check the console for detailed status messages',
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigCard(String title, String value, Color statusColor) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  value,
                  style: AppTypography.bodySmall.copyWith(
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
}
