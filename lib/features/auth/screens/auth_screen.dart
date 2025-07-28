import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../navigation/route_names.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignIn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              const SizedBox(height: 48),
              
              // Auth Form
              _isSignIn ? const SignInScreen() : const SignUpScreen(),
              
              const SizedBox(height: 24),
              
              // Toggle between sign in/up
              _buildToggleButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Welcome Back',
          style: AppTypography.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to save your scan results and access your history',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.mediumGray,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildToggleButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignIn ? "Don't have an account? " : "Already have an account? ",
          style: AppTypography.bodyMedium,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isSignIn = !_isSignIn;
            });
          },
          child: Text(
            _isSignIn ? 'Sign Up' : 'Sign In',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
