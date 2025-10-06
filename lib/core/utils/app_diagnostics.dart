import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../services/tensorflow_service.dart';
import '../services/weather_service.dart';
import '../services/camera_service.dart';

/// App Diagnostics - Test critical app functionality
class AppDiagnostics {
  /// Run comprehensive diagnostics for all app services
  static Future<Map<String, dynamic>> runDiagnostics() async {
    debugPrint('🔍 Running App Diagnostics...');

    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'supabase': await _testSupabase(),
      'tensorflow': await _testTensorFlow(),
      'location': await _testLocation(),
      'camera': await _testCamera(),
    };

    _printDiagnosticsReport(results);
    return results;
  }

  /// Test Supabase connection and schema configuration
  static Future<Map<String, dynamic>> _testSupabase() async {
    debugPrint('🔍 Testing Supabase configuration...');

    try {
      // Test if Supabase is configured
      final isConfigured = SupabaseService.isConfigured();
      if (!isConfigured) {
        return {
          'status': 'error',
          'message': 'Supabase not configured',
          'schema': 'unknown',
        };
      }

      // Test database connection (this will use the plant_disease schema)
      final connectionTest = await SupabaseService.testConnection();

      return {
        'status': connectionTest['success'] ? 'success' : 'error',
        'message': connectionTest['success']
            ? 'Connected to plant_disease schema successfully'
            : connectionTest['error'],
        'schema': 'plant_disease',
        'configured': true,
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Supabase test failed: $e',
        'schema': 'unknown',
        'configured': false,
      };
    }
  }

  /// Test TensorFlow Lite model loading
  static Future<Map<String, dynamic>> _testTensorFlow() async {
    debugPrint('🔍 Testing TensorFlow Lite model...');

    try {
      // Test model initialization
      final isInitialized = await TensorFlowService.initialize();
      final isModelLoaded = TensorFlowService.isModelLoaded;
      final labels = TensorFlowService.labels;

      return {
        'status': isModelLoaded ? 'success' : 'warning',
        'message': isModelLoaded
            ? 'Model loaded successfully'
            : 'Model file not found but app can continue',
        'initialized': isInitialized,
        'modelLoaded': isModelLoaded,
        'labelsCount': labels.length,
        'modelPath': 'assets/models/model.tflite',
        'inputSize': TensorFlowService.modelInputSize,
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'TensorFlow test failed: $e',
        'initialized': false,
        'modelLoaded': false,
        'labelsCount': 0,
      };
    }
  }

  /// Test location services
  static Future<Map<String, dynamic>> _testLocation() async {
    debugPrint('🔍 Testing location services...');

    try {
      final locationResult = await WeatherService.getCurrentLocation();

      return {
        'status': locationResult['success'] ? 'success' : 'error',
        'message': locationResult['success']
            ? 'Location services working'
            : locationResult['error'],
        'hasPermission': locationResult['success'],
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Location test failed: $e',
        'hasPermission': false,
      };
    }
  }

  /// Test camera services
  static Future<Map<String, dynamic>> _testCamera() async {
    debugPrint('🔍 Testing camera services...');

    try {
      final isInitialized = await CameraService.initialize();

      return {
        'status': isInitialized ? 'success' : 'error',
        'message': isInitialized
            ? 'Camera initialized successfully'
            : 'Camera initialization failed',
        'initialized': isInitialized,
        'hasPermission': isInitialized,
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Camera test failed: $e',
        'initialized': false,
        'hasPermission': false,
      };
    }
  }

  /// Print a formatted diagnostics report
  static void _printDiagnosticsReport(Map<String, dynamic> results) {
    const separator = '==================================================';
    debugPrint('\n$separator');
    debugPrint('📊 APP DIAGNOSTICS REPORT');
    debugPrint(separator);
    debugPrint('⏰ Timestamp: ${results['timestamp']}');
    debugPrint('');

    // Supabase Report
    final supabase = results['supabase'] as Map<String, dynamic>;
    debugPrint('🗄️ SUPABASE:');
    debugPrint(
        '  Status: ${_getStatusEmoji(supabase['status'])} ${supabase['status']}');
    debugPrint('  Schema: ${supabase['schema']}');
    debugPrint('  Message: ${supabase['message']}');
    debugPrint('');

    // TensorFlow Report
    final tensorflow = results['tensorflow'] as Map<String, dynamic>;
    debugPrint('🤖 TENSORFLOW LITE:');
    debugPrint(
        '  Status: ${_getStatusEmoji(tensorflow['status'])} ${tensorflow['status']}');
    debugPrint('  Model Loaded: ${tensorflow['modelLoaded'] ? '✅' : '❌'}');
    debugPrint('  Labels Count: ${tensorflow['labelsCount']}');
    debugPrint('  Input Size: ${tensorflow['inputSize'] ?? 'unknown'}');
    debugPrint('  Message: ${tensorflow['message']}');
    debugPrint('');

    // Location Report
    final location = results['location'] as Map<String, dynamic>;
    debugPrint('🌍 LOCATION SERVICES:');
    debugPrint(
        '  Status: ${_getStatusEmoji(location['status'])} ${location['status']}');
    debugPrint('  Permission: ${location['hasPermission'] ? '✅' : '❌'}');
    debugPrint('  Message: ${location['message']}');
    debugPrint('');

    // Camera Report
    final camera = results['camera'] as Map<String, dynamic>;
    debugPrint('📸 CAMERA SERVICES:');
    debugPrint(
        '  Status: ${_getStatusEmoji(camera['status'])} ${camera['status']}');
    debugPrint('  Initialized: ${camera['initialized'] ? '✅' : '❌'}');
    debugPrint('  Permission: ${camera['hasPermission'] ? '✅' : '❌'}');
    debugPrint('  Message: ${camera['message']}');
    debugPrint('');

    // Overall Status
    final overallStatus = _getOverallStatus(results);
    debugPrint(
        '🎯 OVERALL STATUS: ${_getStatusEmoji(overallStatus)} $overallStatus');
    debugPrint('$separator\n');
  }

  /// Get emoji for status
  static String _getStatusEmoji(String status) {
    switch (status) {
      case 'success':
        return '✅';
      case 'warning':
        return '⚠️';
      case 'error':
        return '❌';
      default:
        return '❓';
    }
  }

  /// Determine overall app status
  static String _getOverallStatus(Map<String, dynamic> results) {
    final supabaseStatus = results['supabase']['status'];
    final tensorflowStatus = results['tensorflow']['status'];
    final locationStatus = results['location']['status'];
    final cameraStatus = results['camera']['status'];

    // Critical errors (app won't work)
    if (supabaseStatus == 'error') {
      return 'error';
    }

    // Count successful services
    int successCount = 0;
    if (supabaseStatus == 'success') successCount++;
    if (tensorflowStatus == 'success') successCount++;
    if (locationStatus == 'success') successCount++;
    if (cameraStatus == 'success') successCount++;

    // All services working
    if (successCount == 4) {
      return 'success';
    }

    // Most services working
    if (successCount >= 2) {
      return 'warning';
    }

    // Too many failures
    return 'error';
  }
}
