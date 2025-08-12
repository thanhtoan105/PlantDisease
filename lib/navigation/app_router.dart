import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/auth_screen.dart';
import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/verify_otp_screen.dart';

import '../features/main/main_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/crop_details_screen.dart';
import '../features/home/screens/disease_details_screen.dart';
import '../features/ai_scan/screens/ai_scan_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../shared/widgets/loading_spinner.dart';
import 'route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Wait for auth to initialize
      if (!authProvider.isInitialized) {
        debugPrint('⏳ Waiting for auth initialization...');
        return null; // Show loading screen
      }
      
      // Allow access to forgot password and OTP verification screens without authentication
      if (state.uri.path == RouteNames.forgotPassword ||
          state.uri.path == RouteNames.verifyOtp) {
        return null;
      }

      // Always redirect to onboarding if not completed
      if (!authProvider.onboardingCompleted) {
        debugPrint('📱 Redirecting to onboarding');
        if (state.uri.path != RouteNames.onboarding) {
          return RouteNames.onboarding;
        }
        return null;
      }
      
      // Check if authentication is needed
      if (!authProvider.isAuthenticated) {
        debugPrint('🔐 Redirecting to auth');
        if (state.uri.path != RouteNames.auth) {
          return RouteNames.auth;
        }
        return null;
      }
      
      debugPrint('✅ Navigation allowed');
      return null; // Allow navigation
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          // Show loading screen while auth initializes
          return Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (!authProvider.isInitialized) {
                return const LoadingScreen(message: 'Initializing...');
              }
              
              // Redirect to main screen once initialized
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(RouteNames.main);
              });

              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
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
        path: RouteNames.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: RouteNames.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.verifyOtp,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyOtpScreen(email: email);
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
