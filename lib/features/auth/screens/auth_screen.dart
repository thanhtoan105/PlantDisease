import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_spinner.dart';
import '../../../navigation/route_names.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final result = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.successGreen,
          ),
        );
        context.go(RouteNames.main);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleSkipAuth() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.skipAuth();
    if (mounted) {
      context.go(RouteNames.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const Center(
                child: LoadingSpinner(message: 'Please wait...'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingXl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.spacingXxxl),

                    // Logo/Title
                    Text(
                      'Plant Disease Detection',
                      style: AppTypography.headlineLarge,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppDimensions.spacingLg),

                    Text(
                      'Welcome back',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.mediumGray,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppDimensions.spacingXxxl),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppDimensions.spacingLg),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppDimensions.spacingXxxl),

                    // Sign in button
                    CustomButton(
                      text: 'Sign In',
                      onPressed: _handleSignIn,
                      type: ButtonType.primary,
                    ),

                    const SizedBox(height: AppDimensions.spacingLg),

                    // Navigate to sign up
                    TextButton(
                      onPressed: () => context.go(RouteNames.signUp),
                      child: Text(
                        'Don\'t have an account? Sign Up',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingXl),

                    // Skip auth button
                    CustomButton(
                      text: 'Continue as Guest',
                      onPressed: _handleSkipAuth,
                      type: ButtonType.secondary,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
