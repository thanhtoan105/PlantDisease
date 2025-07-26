import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/providers/weather_provider.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        return GestureDetector(
          onTap: () {
            if (weatherProvider.error != null && weatherProvider.canRetry) {
              // Retry loading weather data
              weatherProvider.refreshWeatherData();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Weather details coming soon')),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.weatherSecondary,
                  AppColors.weatherBackground
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: _buildContent(weatherProvider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(WeatherProvider weatherProvider) {
    if (weatherProvider.isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        ),
      );
    }

    if (weatherProvider.error != null) {
      return SizedBox(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(weatherProvider.errorType),
              size: 32,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              _getErrorTitle(weatherProvider.errorType),
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.errorRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              _getErrorSubtitle(
                  weatherProvider.errorType, weatherProvider.canRetry),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final weather = weatherProvider.currentWeather;
    if (weather == null) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text('No weather data available'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with location
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weatherProvider.selectedCity ?? 'Current Location',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.darkNavy,
                  ),
                ),
                Text(
                  _formatDate(),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.spacingLg),

        // Main temperature display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Temperature
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weather['temperature']}°',
                  style: AppTypography.headlineLarge.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),

            // Weather icon and condition
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  _getWeatherIcon(weather['condition']),
                  size: 60,
                  color: AppColors.weatherOrange,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  weather['condition']?['description'] ?? 'Clear',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.spacingLg),

        // Additional weather info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildWeatherInfo('Humidity', '${weather['humidity']}%'),
            _buildWeatherInfo('Wind', '${weather['windSpeed']} km/h'),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mediumGray,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.darkNavy,
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(Map<String, dynamic>? condition) {
    if (condition == null) return Icons.wb_sunny;

    final main = condition['main']?.toString().toLowerCase() ?? '';

    switch (main) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.cloud;
      default:
        return Icons.wb_sunny;
    }
  }

  String _formatDate() {
    final now = DateTime.now();
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  IconData _getErrorIcon(String? errorType) {
    switch (errorType) {
      case 'permission_denied':
      case 'permission_denied_forever':
        return Icons.location_disabled;
      case 'service_disabled':
        return Icons.location_off;
      case 'location_timeout':
        return Icons.gps_not_fixed;
      case 'config_error':
        return Icons.settings;
      case 'auth_error':
        return Icons.key_off;
      case 'network_error':
        return Icons.wifi_off;
      case 'api_error':
        return Icons.cloud_off;
      default:
        return Icons.error_outline;
    }
  }

  String _getErrorTitle(String? errorType) {
    switch (errorType) {
      case 'permission_denied':
        return 'Location Permission Needed';
      case 'permission_denied_forever':
        return 'Location Access Denied';
      case 'service_disabled':
        return 'Location Services Disabled';
      case 'location_timeout':
        return 'Location Timeout';
      case 'config_error':
        return 'Weather API Not Configured';
      case 'auth_error':
        return 'Invalid Weather API Key';
      case 'network_error':
        return 'Network Connection Error';
      case 'api_error':
        return 'Weather Service Error';
      default:
        return 'Weather Unavailable';
    }
  }

  String _getErrorSubtitle(String? errorType, bool canRetry) {
    switch (errorType) {
      case 'permission_denied':
        return canRetry ? 'Tap to grant permission' : 'Permission required';
      case 'permission_denied_forever':
        return 'Enable in app settings';
      case 'service_disabled':
        return canRetry ? 'Tap to retry' : 'Enable location services';
      case 'location_timeout':
        return canRetry ? 'Tap to try again' : 'Check GPS signal';
      case 'config_error':
        return 'Check .env file configuration';
      case 'auth_error':
        return 'Verify OpenWeatherMap API key';
      case 'network_error':
        return canRetry ? 'Tap to retry' : 'Check internet connection';
      case 'api_error':
        return canRetry ? 'Tap to retry' : 'Service temporarily unavailable';
      default:
        return canRetry ? 'Tap to retry' : 'Try again later';
    }
  }
}
