import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _isGuestMode = false;
  User? _user;
  Session? _session;
  Map<String, dynamic>? _profile;
  String? _error;
  bool _onboardingCompleted = false;
  bool _isInitialized = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuestMode => false;
  User? get user => _user;
  Session? get session => _session;
  Map<String, dynamic>? get profile => _profile;
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
      final isGuestMode = false; // Always disable guest mode
      final wasAuthenticated = prefs.getBool('was_authenticated') ?? false;

      debugPrint('🔍 Auth initialization:');
      debugPrint('  - Onboarding completed: $onboardingCompleted');
      debugPrint('  - Guest mode: $isGuestMode');
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
        'isGuestMode': false, // Always disable guest mode
        'wasAuthenticated': wasAuthenticated,
        'isAuthenticated': isAuthenticated,
        'user': user,
        'session': currentSession,
      };
    } catch (e) {
      debugPrint('Error in background initialization: $e');
      return {
        'onboardingCompleted': false,
        'isGuestMode': false, // Always disable guest mode
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
    _isGuestMode = false; // Always disable guest mode
    _isAuthenticated = result['isAuthenticated'] ?? false;
    _user = result['user'];
    _session = result['session'];

    // Load profile in background if authenticated
    if (_isAuthenticated && _user != null) {
      _loadUserProfileAsync(_user!.id);
    }

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
        debugPrint('✅ User signed in: ${session.user.email}');
        _setUser(session.user);
        _setSession(session);
        await completeOnboarding();
        await _markAsAuthenticated();
        // Load profile in background
        _loadUserProfileAsync(session.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        debugPrint('👋 User signed out');
        await _clearAuthenticationState();
        _logout();
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        debugPrint('🔄 Token refreshed for: ${session.user.email}');
        _setSession(session);
      }
    });
  }

  /// Load user profile in background
  Future<void> _loadUserProfileAsync(String userId) async {
    try {
      final response = await compute(_loadProfileInBackground, userId);
      if (response != null) {
        _profile = response;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  /// Background profile loading function
  static Future<Map<String, dynamic>?> _loadProfileInBackground(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('profiles').select().eq('id', userId).single();
      return response;
    } catch (e) {
      debugPrint('Error loading profile in background: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> signUp(
    String email,
    String password, {
    Map<String, dynamic>? userData,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': userData?['username'] ?? email.split('@')[0],
          'phone': userData?['phone'],
        },
      );

      if (response.user != null) {
        // Create user profile in background
        unawaited(_createUserProfileAsync(response.user!.id, {
          'username': userData?['username'] ?? email.split('@')[0],
          'role': 'user',
          'location': userData?['location'],
        }));

        return {
          'success': true,
          'message':
              'Account created successfully! Please check your email for verification.',
        };
      }

      return {'success': false, 'error': 'Failed to create account'};
    } catch (e) {
      final errorMessage = _parseAuthError(e.toString());
      _setError(errorMessage);
      return {'success': false, 'error': errorMessage};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        return {'success': true, 'message': 'Signed in successfully!'};

      }

      return {'success': false, 'error': 'Failed to sign in'};
    } catch (e) {
      final errorMessage = _parseAuthError(e.toString());
      _setError(errorMessage);
      return {'success': false, 'error': errorMessage};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabase.auth.resetPasswordForEmail(email);

      return {
        'success': true,
        'message': 'Password reset email sent! Please check your inbox.',
      };
    } catch (e) {
      final errorMessage = _parseAuthError(e.toString());
      _setError(errorMessage);
      return {'success': false, 'error': errorMessage};
    } finally {
      _setLoading(false);
    }
  }

  /// Parse authentication errors to provide user-friendly messages
  String _parseAuthError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (error.contains('Email not confirmed')) {
      return 'Please check your email and click the confirmation link.';
    } else if (error.contains('Too many requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (error.contains('User not found')) {
      return 'No account found with this email address.';
    } else if (error.contains('Invalid email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('Password should be at least')) {
      return 'Password must be at least 6 characters long.';
    } else if (error.contains('User already registered')) {
      return 'An account with this email already exists.';
    }
    return error;
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _logout();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    _onboardingCompleted = true;
    notifyListeners();
  }

  Future<void> skipAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('guest_mode', true);
    await prefs.setBool('onboarding_completed', true);
    _isGuestMode = true;
    _onboardingCompleted = true;
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_completed');
    await prefs.remove('guest_mode');
    _onboardingCompleted = false;
    _isGuestMode = false;
    notifyListeners();
  }

  /// Create user profile in background
  Future<void> _createUserProfileAsync(
      String userId, Map<String, dynamic> profileData) async {
    try {
      await compute(_createProfileInBackground, {
        'userId': userId,
        'profileData': profileData,
      });
    } catch (e) {
      debugPrint('Error creating user profile: $e');
    }
  }

  /// Background profile creation function
  static Future<void> _createProfileInBackground(Map<String, dynamic> data) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('profiles').insert({
        'id': data['userId'],
        ...data['profileData'],
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating profile in background: $e');
    }
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
    _profile = null;
    _isAuthenticated = false;
    _isGuestMode = false;
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
    return _onboardingCompleted || _isAuthenticated || _isGuestMode;
  }
}
