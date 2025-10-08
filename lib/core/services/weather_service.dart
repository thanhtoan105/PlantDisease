import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../config/env_config.dart';

class WeatherService {
  // OpenWeatherMap API configuration from environment
  static String get _baseUrl => EnvConfig.weatherApiBaseUrl;
  static String get _apiKey => EnvConfig.weatherApiKey;

  /// Test API connection and validate configuration
  static Future<Map<String, dynamic>> testApiConnection() async {
    try {
      debugPrint('🌤️ Testing weather API connection...');
      debugPrint('🔗 API Base URL: $_baseUrl');
      debugPrint('🔑 API Key: ${_apiKey.isNotEmpty ? "✅ Set" : "❌ Missing"}');

      if (_apiKey.isEmpty || _apiKey == 'YOUR_WEATHER_API_KEY') {
        return {
          'success': false,
          'error':
              'Weather API key is not configured. Please check your .env file.',
          'errorType': 'config_error',
        };
      }

      // Test with a known location (London) using One Call API 3.0
      final url = Uri.parse(
        '$_baseUrl/onecall?lat=51.5074&lon=-0.1278&appid=$_apiKey&units=metric&exclude=minutely,hourly,daily,alerts',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        debugPrint('✅ Weather API connection successful');
        return {
          'success': true,
          'message': 'Weather API connection successful',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Invalid API key. Please check your OpenWeatherMap API key.',
          'errorType': 'auth_error',
        };
      } else {
        return {
          'success': false,
          'error':
              'Weather API error: ${response.statusCode} - ${response.body}',
          'errorType': 'api_error',
        };
      }
    } catch (e) {
      debugPrint('❌ Weather API connection test failed: $e');
      return {
        'success': false,
        'error': 'Failed to connect to weather service: $e',
        'errorType': 'network_error',
      };
    }
  }

  /// Get current weather data for coordinates using One Call API 3.0
  static Future<Map<String, dynamic>> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      debugPrint('🌤️ Fetching weather for: $latitude, $longitude');

      final url = Uri.parse(
        '$_baseUrl/onecall?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric&exclude=minutely,hourly,daily,alerts',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('✅ Weather data fetched successfully');
        return {
          'success': true,
          'data': _processOneCallWeatherData(data),
        };
      } else if (response.statusCode == 401) {
        debugPrint('❌ Weather API authentication failed');
        return {
          'success': false,
          'error': 'Invalid API key. Please check your OpenWeatherMap API key.',
          'errorType': 'auth_error',
        };
      } else {
        debugPrint('❌ Weather API error: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Weather service error: ${response.statusCode}',
          'errorType': 'api_error',
        };
      }
    } catch (e) {
      debugPrint('❌ Weather API error: $e');
      return {
        'success': false,
        'error': 'Failed to fetch weather data: $e',
        'errorType': 'network_error',
      };
    }
  }

  /// Get current location with progressive timeout and fallback
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      debugPrint('🌍 Getting current location...');

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location services are disabled');
        return {
          'success': false,
          'error':
              'Location services are disabled. Please enable location services in your device settings.',
          'errorType': 'service_disabled',
        };
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📍 Current location permission: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('📍 Requested location permission: $permission');

        if (permission == LocationPermission.denied) {
          return {
            'success': false,
            'error':
                'Location permission denied. Please grant location permission to get weather data.',
            'errorType': 'permission_denied',
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'success': false,
          'error':
              'Location permission permanently denied. Please enable location permission in app settings.',
          'errorType': 'permission_denied_forever',
        };
      }

      // Get current position with progressive timeout and fallback
      Position? position;

      // Try high accuracy first with longer timeout (increased from 45 to 60 seconds)
      try {
        debugPrint('📍 Attempting high accuracy location...');
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 45), // Increased from 30
          ),
        ).timeout(
          const Duration(seconds: 60), // Increased from 45
        );
        debugPrint('✅ High accuracy location obtained');
      } catch (e) {
        debugPrint('⚠️ High accuracy failed: $e');

        // Fallback to medium accuracy with shorter timeout (increased timeouts)
        try {
          debugPrint('📍 Attempting medium accuracy location...');
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 30), // Increased from 20
            ),
          ).timeout(
            const Duration(seconds: 45), // Increased from 30
          );
          debugPrint('✅ Medium accuracy location obtained');
        } catch (e2) {
          debugPrint('⚠️ Medium accuracy failed: $e2');

          // Final fallback to low accuracy (increased timeouts)
          try {
            debugPrint('📍 Attempting low accuracy location...');
            position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.low,
                timeLimit: Duration(seconds: 20), // Increased from 15
              ),
            ).timeout(
              const Duration(seconds: 30), // Increased from 20
            );
            debugPrint('✅ Low accuracy location obtained');
          } catch (e3) {
            debugPrint('❌ All location attempts failed: $e3');
            // Try to get last known position as final fallback
            try {
              position = await Geolocator.getLastKnownPosition(
                forceAndroidLocationManager: true,
              );
              if (position != null) {
                debugPrint(
                    '✅ Using last known position (${position.latitude}, ${position.longitude})');
                debugPrint(
                    '⚠️ Last known position age: ${DateTime.now().difference(position.timestamp).inMinutes} minutes');
              }
            } catch (e4) {
              debugPrint('❌ Last known position also failed: $e4');
            }

            if (position == null) {
              return {
                'success': false,
                'error':
                    'Unable to get location after multiple attempts. Please check your GPS settings, ensure you have a clear view of the sky, and try again.',
                'errorType': 'location_timeout',
              };
            }
          }
        }
      }

      debugPrint(
          '✅ Location obtained: ${position.latitude}, ${position.longitude}');

      // Get location name with error handling
      String locationName = 'Unknown Location';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 5));

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          locationName =
              '${placemark.locality ?? ''}, ${placemark.country ?? ''}'
                  .replaceAll(RegExp(r'^,\s*|,\s*$'), '');
          if (locationName.isEmpty) {
            locationName = 'Unknown Location';
          }
        }
      } catch (e) {
        debugPrint('⚠️ Failed to get location name: $e');
        // Continue with coordinates even if reverse geocoding fails
      }

      return {
        'success': true,
        'data': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'name': locationName,
        },
      };
    } catch (e) {
      debugPrint('❌ Location service error: $e');
      return {
        'success': false,
        'error': 'Location service error: ${e.toString()}',
      };
    }
  }

  /// Get mock weather data for fallback
  static Map<String, dynamic> getMockWeatherData() {
    return {
      'success': true,
      'data': {
        'temperature': 23,
        'feelsLike': 25,
        'description': 'Partly Cloudy',
        'icon': '03d',
        'humidity': 65,
        'windSpeed': 5.2,
        'location': 'Sample Location',
        'country': 'Sample Country',
        'timestamp': DateTime.now(),
      },
    };
  }

  /// Search cities by name
  static Future<Map<String, dynamic>> searchCities(String query) async {
    try {
      final url = Uri.parse(
        'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final cities = data
            .map((city) => {
                  'name': city['name'],
                  'country': city['country'],
                  'state': city['state'],
                  'latitude': city['lat'],
                  'longitude': city['lon'],
                })
            .toList();

        return {
          'success': true,
          'data': cities,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to search cities: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('City search error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Process weather data from One Call API 3.0
  static Map<String, dynamic> _processOneCallWeatherData(
      Map<String, dynamic> data) {
    final current = data['current'];
    return {
      'temperature': (current['temp'] as num).round(),
      'feelsLike': (current['feels_like'] as num).round(),
      'description': current['weather'][0]['description'],
      'icon': current['weather'][0]['icon'],
      'humidity': current['humidity'],
      'windSpeed': (current['wind_speed'] as num).toDouble(),
      'timestamp': DateTime.now(),
      'latitude': data['lat'],
      'longitude': data['lon'],
    };
  }
}
