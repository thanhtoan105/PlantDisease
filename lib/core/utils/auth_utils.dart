import 'package:flutter/foundation.dart';

/// Utility class for authentication-related functions
class AuthUtils {
  /// Parse authentication errors to provide user-friendly messages
  static String parseAuthError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Invalid password. Please try again.';
    } else if (error.contains('Email not confirmed')) {
      return 'Please check your email and click the confirmation link.';
    } else if (error.contains('Too many requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (error.contains('User not found')) {
      return 'Account not found. You need to create an account first.';
    } else if (error.contains('Invalid email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('Password should be at least')) {
      return 'Password must be at least 6 characters long.';
    } else if (error.contains('User already registered')) {
      return 'An account with this email already exists.';
    }
    return error;
  }

  /// Execute an auth operation with standard error handling and loading state management
  static Future<Map<String, dynamic>> executeAuthOperation({
    required Future<Map<String, dynamic>> Function() operation,
    required Function(bool) setLoading,
    required Function() clearError,
    required Function(String) setError,
  }) async {
    try {
      setLoading(true);
      clearError();

      return await operation();
    } catch (e) {
      final errorMessage = parseAuthError(e.toString());
      setError(errorMessage);
      debugPrint('Authentication error: $errorMessage');
      return {'success': false, 'error': errorMessage};
    } finally {
      setLoading(false);
    }
  }
}
