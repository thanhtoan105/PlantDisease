import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/auth_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/main/main_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/crop_library_screen.dart';
import '../features/home/screens/crop_details_screen.dart';
import '../features/home/screens/disease_details_screen.dart';
import '../features/ai_scan/screens/ai_scan_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import 'route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isOnboardingCompleted = authProvider.onboardingCompleted;
      final isAuthenticated = authProvider.isAuthenticated;
      final isGuestMode = authProvider.isGuestMode;
      final isLoading = authProvider.isLoading;
      final shouldSkipOnboarding = authProvider.shouldSkipOnboarding;

      // Don't redirect while loading
      if (isLoading) return null;

      final currentPath = state.uri.path;

      debugPrint('🧭 Router redirect check:');
      debugPrint('  - Current path: $currentPath');
      debugPrint('  - Is authenticated: $isAuthenticated');
      debugPrint('  - Is guest mode: $isGuestMode');
      debugPrint('  - Onboarding completed: $isOnboardingCompleted');
      debugPrint('  - Should skip onboarding: $shouldSkipOnboarding');

      // If authenticated or in guest mode, redirect to main app
      if (isAuthenticated || isGuestMode) {
        if (currentPath == RouteNames.onboarding ||
            currentPath == RouteNames.auth ||
            currentPath == RouteNames.signUp ||
            currentPath == '/') {
          debugPrint('🏠 Redirecting authenticated user to main');
          return RouteNames.main;
        }
        // Allow navigation to other authenticated routes
        return null;
      }

      // If should skip onboarding (was previously authenticated), go to auth
      if (shouldSkipOnboarding && !isAuthenticated && !isGuestMode) {
        if (currentPath == RouteNames.onboarding || currentPath == '/') {
          debugPrint('🔐 Skipping onboarding, redirecting to auth');
          return RouteNames.auth;
        }
        // Allow navigation to auth/signup
        if (currentPath == RouteNames.auth ||
            currentPath == RouteNames.signUp) {
          return null;
        }
      }

      // If not onboarded and shouldn't skip, go to onboarding
      if (!shouldSkipOnboarding && currentPath != RouteNames.onboarding) {
        debugPrint('👋 Redirecting to onboarding');
        return RouteNames.onboarding;
      }

      // If onboarded but not authenticated and not in guest mode, go to auth
      if (isOnboardingCompleted &&
          !isAuthenticated &&
          !isGuestMode &&
          currentPath != RouteNames.auth &&
          currentPath != RouteNames.signUp &&
          currentPath != RouteNames.onboarding) {
        debugPrint('🔐 Redirecting to auth');
        return RouteNames.auth;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) {
          // This will be handled by the main redirect logic above
          return null;
        },
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: RouteNames.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RouteNames.main,
        builder: (context, state) => const MainScreen(),
        routes: [
          GoRoute(
            path: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: 'ai-scan',
            builder: (context, state) => const AiScanScreen(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.cropLibrary,
        builder: (context, state) => const CropLibraryScreen(),
      ),
      GoRoute(
        path: '${RouteNames.cropDetails}/:cropId',
        builder: (context, state) {
          final cropId = state.pathParameters['cropId']!;
          final crop = state.extra as Map<String, dynamic>?;
          return CropDetailsScreen(
            cropId: cropId,
            crop: crop,
          );
        },
      ),
      GoRoute(
        path: '/disease-details',
        builder: (context, state) {
          final disease = state.extra as Map<String, dynamic>? ?? {};
          return DiseaseDetailsScreen(disease: disease);
        },
      ),
    ],
  );
}
