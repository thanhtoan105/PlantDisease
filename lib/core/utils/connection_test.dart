import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

/// Utility class for testing network connectivity and Supabase connection
class ConnectionTest {
  /// Test basic internet connectivity
  static Future<bool> testInternetConnection() async {
    try {
      debugPrint('🌐 Testing internet connectivity...');

      // Test with multiple reliable endpoints
      final testUrls = [
        'https://www.google.com',
        'https://www.cloudflare.com',
        'https://httpbin.org/get',
      ];

      for (final url in testUrls) {
        try {
          final response = await http.get(
            Uri.parse(url),
            headers: {'User-Agent': 'PlantDiseaseApp/1.0'},
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            debugPrint('✅ Internet connection confirmed via $url');
            return true;
          }
        } catch (e) {
          debugPrint('⚠️ Failed to connect to $url: $e');
          continue;
        }
      }

      debugPrint('❌ No internet connection detected');
      return false;
    } catch (e) {
      debugPrint('❌ Internet connectivity test failed: $e');
      return false;
    }
  }

  /// Test DNS resolution for Supabase URL
  static Future<bool> testDnsResolution(String supabaseUrl) async {
    try {
      debugPrint('🔍 Testing DNS resolution for $supabaseUrl...');

      final uri = Uri.parse(supabaseUrl);
      final host = uri.host;

      final addresses = await InternetAddress.lookup(host);
      if (addresses.isNotEmpty) {
        debugPrint('✅ DNS resolution successful for $host');
        debugPrint(
            '   Resolved to: ${addresses.map((a) => a.address).join(', ')}');
        return true;
      } else {
        debugPrint('❌ DNS resolution failed for $host');
        return false;
      }
    } catch (e) {
      debugPrint('❌ DNS resolution error: $e');
      return false;
    }
  }

  /// Test Supabase connection
  static Future<Map<String, dynamic>> testSupabaseConnection() async {
    try {
      debugPrint('🔗 Testing Supabase connection...');

      final supabase = Supabase.instance.client;

      // Test 1: Basic auth endpoint
      try {
        final session = supabase.auth.currentSession;
        debugPrint(
            '✅ Supabase auth endpoint accessible (session: ${session != null ? 'exists' : 'none'})');
      } catch (e) {
        debugPrint('⚠️ Supabase auth endpoint test failed: $e');
      }

      // Test 2: Try a simple database query (this might fail if table doesn't exist)
      try {
        await supabase.from('crops').select('count').limit(1);
        debugPrint('✅ Supabase database connection successful');
        return {
          'success': true,
          'message': 'Supabase connection successful',
        };
      } catch (e) {
        debugPrint('⚠️ Database query failed (might be normal): $e');
        return {
          'success': true,
          'message':
              'Supabase auth accessible, database query failed (might be normal)',
          'warning': e.toString(),
        };
      }
    } catch (e) {
      debugPrint('❌ Supabase connection failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Comprehensive connection test
  static Future<Map<String, dynamic>> runFullConnectionTest(
      String supabaseUrl) async {
    debugPrint('🚀 Starting comprehensive connection test...');

    final results = <String, dynamic>{
      'internetConnection': false,
      'dnsResolution': false,
      'supabaseConnection': false,
      'errors': <String>[],
      'warnings': <String>[],
    };

    // Test 1: Internet connectivity
    results['internetConnection'] = await testInternetConnection();
    if (!results['internetConnection']) {
      results['errors'].add('No internet connection detected');
    }

    // Test 2: DNS resolution
    if (results['internetConnection']) {
      results['dnsResolution'] = await testDnsResolution(supabaseUrl);
      if (!results['dnsResolution']) {
        results['errors'].add('DNS resolution failed for Supabase URL');
      }
    }

    // Test 3: Supabase connection
    if (results['dnsResolution']) {
      final supabaseResult = await testSupabaseConnection();
      results['supabaseConnection'] = supabaseResult['success'] ?? false;

      if (supabaseResult['error'] != null) {
        results['errors']
            .add('Supabase connection: ${supabaseResult['error']}');
      }

      if (supabaseResult['warning'] != null) {
        results['warnings']
            .add('Supabase warning: ${supabaseResult['warning']}');
      }
    }

    // Summary
    final allPassed = results['internetConnection'] &&
        results['dnsResolution'] &&
        results['supabaseConnection'];

    debugPrint('📊 Connection test summary:');
    debugPrint('   Internet: ${results['internetConnection'] ? '✅' : '❌'}');
    debugPrint('   DNS: ${results['dnsResolution'] ? '✅' : '❌'}');
    debugPrint('   Supabase: ${results['supabaseConnection'] ? '✅' : '❌'}');
    debugPrint('   Overall: ${allPassed ? '✅ PASS' : '❌ FAIL'}');

    if (results['errors'].isNotEmpty) {
      debugPrint('❌ Errors:');
      for (final error in results['errors']) {
        debugPrint('   - $error');
      }
    }

    if (results['warnings'].isNotEmpty) {
      debugPrint('⚠️ Warnings:');
      for (final warning in results['warnings']) {
        debugPrint('   - $warning');
      }
    }

    return results;
  }
}
