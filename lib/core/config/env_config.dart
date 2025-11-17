import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration service
class EnvConfig {
  static bool _isInitialized = false;

  /// Initialize environment variables
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      _isInitialized = true;
      debugPrint('✅ Environment variables loaded successfully');
    } catch (e) {
      debugPrint('⚠️ Failed to load .env file: $e');
      debugPrint('📝 Make sure .env file exists in the project root');
      _isInitialized = false;
    }
  }

  /// Check if environment is initialized
  static bool get isInitialized => _isInitialized;

  /// Get environment variable with fallback
  static String _getEnv(String key, {String defaultValue = ''}) {
    if (!_isInitialized) {
      debugPrint(
          '⚠️ Environment not initialized. Using default value for $key');
      return defaultValue;
    }

    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      debugPrint(
          '⚠️ Environment variable $key not found. Using default value.');
      return defaultValue;
    }

    return value;
  }

  // Weather API Configuration
  static String get weatherApiKey => _getEnv(
        'WEATHER_API_KEY',
        defaultValue: 'YOUR_WEATHER_API_KEY',
      );

  static String get weatherApiBaseUrl => _getEnv(
        'WEATHER_API_BASE_URL',
        defaultValue: 'https://api.openweathermap.org/data/3.0',
      );

  // Supabase Configuration
  static String get supabaseUrl => _getEnv(
        'SUPABASE_URL',
        defaultValue: '',
      );

  static String get supabaseAnonKey => _getEnv(
        'SUPABASE_ANON_KEY',
        defaultValue: '',
      );

  // Gemini AI Configuration
  static String get geminiApiKey => _getEnv(
        'GEMINI_API_KEY',
        defaultValue: '',
      );

  /// Validate that all required environment variables are set
  static bool validateConfig() {
    final requiredVars = {
      'WEATHER_API_KEY': weatherApiKey,
      'WEATHER_API_BASE_URL': weatherApiBaseUrl,
      'SUPABASE_URL': supabaseUrl,
      'SUPABASE_ANON_KEY': supabaseAnonKey,
      'GEMINI_API_KEY': geminiApiKey,
    };

    bool isValid = true;
    for (final entry in requiredVars.entries) {
      if (entry.value.isEmpty || entry.value.startsWith('YOUR_')) {
        debugPrint('❌ Missing or invalid environment variable: ${entry.key}');
        isValid = false;
      }
    }

    if (isValid) {
      debugPrint('✅ All environment variables are properly configured');
    } else {
      debugPrint(
          '⚠️ Some environment variables are missing. Check your .env file');
    }

    return isValid;
  }

  /// Print configuration status (for debugging)
  static void printConfigStatus() {
    debugPrint('🔧 Environment Configuration Status:');
    debugPrint('  Initialized: $_isInitialized');
    debugPrint(
        '  Weather API Key: ${weatherApiKey.isNotEmpty ? "✅ Set" : "❌ Missing"}');
    debugPrint(
        '  Weather API URL: ${weatherApiBaseUrl.isNotEmpty ? "✅ Set" : "❌ Missing"}');
    debugPrint(
        '  Supabase URL: ${supabaseUrl.isNotEmpty ? "✅ Set" : "❌ Missing"}');
    debugPrint(
        '  Supabase Key: ${supabaseAnonKey.isNotEmpty ? "✅ Set" : "❌ Missing"}');
    debugPrint(
        '  Gemini API Key: ${geminiApiKey.isNotEmpty ? "✅ Set" : "❌ Missing"}');
  }
}
