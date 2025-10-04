import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/auth_utils.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  User? _user;
  Session? _session;
  String? _error;
  bool _onboardingCompleted = false;
  bool _isInitialized = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;
  Session? get session => _session;
  String? get error => _error;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get isInitialized => _isInitialized;

  final SupabaseClient _supabase = Supabase.instance.client;

  AuthProvider() {
    // Initialize auth in background to prevent main thread blocking
    _initializeAuthAsync();
    _setupAuthListener();
  }

  /// Initialize auth in background thread to prevent main thread blocking
  Future<void> _initializeAuthAsync() async {
    try {
      debugPrint('🔄 Starting auth initialization...');

      // Perform initialization on main thread (Supabase session needs main thread)
      await _performInitialization();

      debugPrint('✅ Auth initialization completed successfully');
    } catch (e) {
      debugPrint('❌ Auth initialization error: $e');
      _setError('Failed to initialize authentication: ${e.toString()}');
    } finally {
      _setLoading(false);
      _isInitialized = true;
      debugPrint('✅ Auth initialization finished, loading: $_isLoading');
    }
  }

  /// Perform initialization on main thread
  Future<void> _performInitialization() async {
    try {
      debugPrint('🔄 Performing initialization...');

      // Check onboarding status and previous auth state
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      final wasAuthenticated = prefs.getBool('was_authenticated') ?? false;

      debugPrint('🔍 Auth initialization:');
      debugPrint('  - Onboarding completed: $onboardingCompleted');
      debugPrint('  - Was authenticated: $wasAuthenticated');

      // Check current session (must be on main thread)
      final session = _supabase.auth.currentSession;

      if (session != null) {
        // If a session exists, restore the user state
        _isAuthenticated = true;
        _user = session.user;
        _session = session;
        _onboardingCompleted = true; // User with session should skip onboarding

        // Ensure onboarding is marked as completed
        if (!onboardingCompleted) {
          await prefs.setBool('onboarding_completed', true);
        }

        debugPrint('✅ Existing session restored successfully');
        debugPrint('  - User: ${session.user.email}');
      } else {
        debugPrint('ℹ️ No existing session found');
        _isAuthenticated = false;
        _user = null;
        _session = null;
        _onboardingCompleted = onboardingCompleted;

        // If user was previously authenticated, they should skip onboarding
        if (wasAuthenticated && !onboardingCompleted) {
          debugPrint('📝 User was previously authenticated, marking onboarding as completed');
          await prefs.setBool('onboarding_completed', true);
          _onboardingCompleted = true;
        }
      }

      debugPrint('✅ Initialization state updated');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error in initialization: $e');
      _onboardingCompleted = false;
      _isAuthenticated = false;
      _user = null;
      _session = null;
      rethrow;
    }
  }

  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      debugPrint('🔐 Auth state changed: $event');

      if (event == AuthChangeEvent.signedIn && session != null) {
        debugPrint('✅ User signed in: {session.user.email}');
        _setUser(session.user);
        _setSession(session);
        await completeOnboarding();
        await _markAsAuthenticated();
      } else if (event == AuthChangeEvent.signedOut) {
        debugPrint('👋 User signed out');
        await _clearAuthenticationState();
        _logout();
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        debugPrint('🔄 Token refreshed for: {session.user.email}');
        _setSession(session);
      }
    });
  }

  Future<Map<String, dynamic>> signUp(
    String email,
    String password, {
    Map<String, dynamic>? userData,
  }) async {
    return AuthUtils.executeAuthOperation(
      operation: () async {
        // First check if email already exists
        final emailCheckResult = await checkEmailExists(email);

        if (emailCheckResult['success'] && emailCheckResult['exists'] == true) {
          // Email already exists - don't allow signup
          return {
            'success': false,
            'error': 'The email already created. Please sign in',
          };
        }

        // Email doesn't exist, proceed with signup
        final response = await _supabase.auth.signUp(
          email: email,
          password: password,
          data: {
            'phone': userData?['phone'],
          },
        );

        if (response.user != null) {
          return {
            'success': true,
            'message': 'Account created successfully! Please check your email for verification.',
          };
        }

        return {'success': false, 'error': 'Failed to create account'};
      },
      setLoading: _setLoading,
      clearError: _clearError,
      setError: _setError,
    );
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    return AuthUtils.executeAuthOperation(
      operation: () async {
        // First check if email exists
        final emailCheckResult = await checkEmailExists(email);

        if (emailCheckResult['success'] && emailCheckResult['exists'] == false) {
          // Email doesn't exist - show helpful message
          return {
            'success': false,
            'error': 'Your account has not been created yet. Please sign up first',
          };
        }

        // Email exists, proceed with sign in
        final response = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.session != null) {
          return {'success': true, 'message': 'Signed in successfully!'};
        }

        return {'success': false, 'error': 'Failed to sign in'};
      },
      setLoading: _setLoading,
      clearError: _clearError,
      setError: _setError,
    );
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    return AuthUtils.executeAuthOperation(
      operation: () async {
        await _supabase.auth.resetPasswordForEmail(email);

        return {
          'success': true,
          'message': 'Password reset email sent! Please check your inbox.',
        };
      },
      setLoading: _setLoading,
      clearError: _clearError,
      setError: _setError,
    );
  }

  /// Check if email exists in Supabase authentication using Edge Function
  Future<Map<String, dynamic>> checkEmailExists(String email) async {
    return AuthUtils.executeAuthOperation(
      operation: () async {
        try {
          debugPrint('🔍 Checking email existence using Edge Function for: $email');

          // Call the Edge Function to check email existence
          final response = await _supabase.functions.invoke(
            'check-email-exists',
            body: {'email': email.trim()},
          );

          // Check if the function call itself failed
          if (response.data == null) {
            debugPrint('❌ Edge Function returned null data');
            // Fallback to password check method if Edge Function fails
            return await _checkEmailExistsFallback(email);
          }

          final data = response.data;
          if (data['success'] == true) {
            final exists = data['exists'] ?? false;
            final message = data['message'] ??
                (exists ? 'Email exists in the system' : 'Your account has not been created yet!');

            debugPrint(exists ? '✅ User exists' : '❌ User does not exist');

            return {
              'success': true,
              'exists': exists,
              'message': message,
            };
          } else {
            debugPrint('⚠️ Edge Function returned success: false');
            // Fallback to password check method
            return await _checkEmailExistsFallback(email);
          }
        } catch (e) {
          debugPrint('❌ Error calling Edge Function: $e');
          // Fallback to password check method if Edge Function is unavailable
          return await _checkEmailExistsFallback(email);
        }
      },
      setLoading: _setLoading,
      clearError: _clearError,
      setError: _setError,
    );
  }

  /// Fallback method to check email existence using password attempt
  Future<Map<String, dynamic>> _checkEmailExistsFallback(String email) async {
    try {
      // Try to sign in with a wrong password to get error details
      await _supabase.auth.signInWithPassword(
        email: email,
        password: 'definitely_wrong_password_12345!@#',
      );

      // If somehow this succeeds, user exists
      return {
        'success': true,
        'exists': true,
        'message': 'Email exists in the system',
      };
    } catch (e) {
      String errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('invalid login credentials') ||
          errorMessage.contains('email not confirmed')) {
        // User exists but wrong password or unconfirmed email
        return {
          'success': true,
          'exists': true,
          'message': 'Email exists in the system',
        };
      } else if (errorMessage.contains('user not found') ||
                 errorMessage.contains('email not found')) {
        // User doesn't exist
        return {
          'success': true,
          'exists': false,
          'message': 'Your account has not been created yet!',
        };
      } else {
        // For unknown errors, assume user exists
        return {
          'success': true,
          'exists': true,
          'message': 'Email verification completed',
        };
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _logout();
    } catch (e) {
      _setError(AuthUtils.parseAuthError(e.toString()));
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    _onboardingCompleted = true;
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_completed');
    _onboardingCompleted = false;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUser(User? user) {
    _user = user;
    _isAuthenticated = user != null;
    notifyListeners();
  }

  void _setSession(Session? session) {
    _session = session;
    _isAuthenticated = session != null;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void _logout() {
    _user = null;
    _session = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  /// Mark user as having been authenticated (for onboarding skip logic)
  Future<void> _markAsAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('was_authenticated', true);
    debugPrint('📝 Marked user as previously authenticated');
  }

  /// Clear authentication state from persistent storage
  Future<void> _clearAuthenticationState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('was_authenticated');
    debugPrint('🗑️ Cleared authentication state');
  }

  /// Check if user should skip onboarding (either completed or was previously authenticated)
  bool get shouldSkipOnboarding {
    return _onboardingCompleted || _isAuthenticated;
  }
}
