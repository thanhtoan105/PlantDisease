import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/auth_screen.dart';

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
      final currentPath = state.uri.path;

      debugPrint('🧭 Router redirect check (BYPASS AUTH MODE):');
      debugPrint('  - Current path: $currentPath');

      // Always redirect from root path to main screen (skip auth/onboarding completely)
      if (currentPath == '/') {
        debugPrint('🏠 Redirecting directly to main (skip auth/onboarding)');
        return RouteNames.main;
      }

      // Redirect any auth/onboarding routes to main screen
      if (currentPath == RouteNames.onboarding ||
          currentPath == RouteNames.auth) {
        debugPrint('🏠 Redirecting auth/onboarding to main (bypassed)');
        return RouteNames.main;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          // Since we're bypassing auth, redirect immediately to main
          // This should never be reached due to redirect logic, but just in case
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(RouteNames.main);
          });

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.auth,
        builder: (context, state) {
          final initialTab = state.uri.queryParameters['tab'];
          return AuthScreen(initialTab: initialTab);
        },
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
          final initialTab = state.uri.queryParameters['tab'];
          final crop = state.extra as Map<String, dynamic>?;
          return CropDetailsScreen(
            cropId: cropId,
            crop: crop,
            initialTab: initialTab,
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
