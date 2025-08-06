import 'dart:async';
import 'dart:isolate';
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
      debugPrint('🔄 Starting auth initialization in background...');
      
      // Use compute to run heavy operations in background
      final result = await compute(_performInitializationInBackground, null);
      
      // Update state on main thread
      _updateStateFromBackground(result);
      
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

  /// Background initialization function
  static Future<Map<String, dynamic>> _performInitializationInBackground(dynamic _) async {
    try {
      debugPrint('🔄 Performing initialization in background...');

      // Check onboarding status and previous auth state
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      final wasAuthenticated = prefs.getBool('was_authenticated') ?? false;

      debugPrint('🔍 Auth initialization:');
      debugPrint('  - Onboarding completed: $onboardingCompleted');
      debugPrint('  - Was authenticated: $wasAuthenticated');

      // Add a small delay to ensure Supabase is fully initialized
      await Future.delayed(const Duration(milliseconds: 50));

      // Check current session
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;
      bool isAuthenticated = false;
      User? user;
      Session? currentSession;

      if (session != null) {
        // If a session exists, assume the user is authenticated.
        // The Supabase client will handle token refreshing automatically.
        isAuthenticated = true;
        user = session.user;
        currentSession = session;
        debugPrint('✅ Existing session restored successfully from local storage');
      } else {
        debugPrint('ℹ️ No existing session found');
      }

      return {
        'onboardingCompleted': onboardingCompleted,
        'wasAuthenticated': wasAuthenticated,
        'isAuthenticated': isAuthenticated,
        'user': user,
        'session': currentSession,
      };
    } catch (e) {
      debugPrint('Error in background initialization: $e');
      return {
        'onboardingCompleted': false,
        'wasAuthenticated': false,
        'isAuthenticated': false,
        'user': null,
        'session': null,
      };
    }
  }

  /// Update state from background initialization results
  void _updateStateFromBackground(Map<String, dynamic> result) {
    _onboardingCompleted = result['onboardingCompleted'] ?? false;
    _isAuthenticated = result['isAuthenticated'] ?? false;
    _user = result['user'];
    _session = result['session'];

    // If user was previously authenticated but no session exists,
    // they should still skip onboarding but go to auth screen
    if (result['wasAuthenticated'] == true && !_isAuthenticated && !_onboardingCompleted) {
      debugPrint('📝 User was previously authenticated, marking onboarding as completed');
      completeOnboarding();
    }

    debugPrint('✅ Background initialization state updated');
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
