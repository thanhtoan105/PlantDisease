import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          _buildEmailField(),
          
          const SizedBox(height: AppDimensions.spacingLg),
          
          // Password Field
          _buildPasswordField(),
          
          const SizedBox(height: AppDimensions.spacingLg),
          
          // Forgot Password
          _buildForgotPassword(),
          
          const SizedBox(height: AppDimensions.spacingXl),
          
          // Sign In Button
          _buildSignInButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        filled: true,
        fillColor: AppColors.white,
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
      onChanged: (_) {
        // Clear errors when user starts typing
        final authProvider = context.read<AuthProvider>();
        if (authProvider.error != null) {
          authProvider.clearError();
        }
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      onChanged: (_) {
        // Clear errors when user starts typing
        final authProvider = context.read<AuthProvider>();
        if (authProvider.error != null) {
          authProvider.clearError();
        }
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Implement forgot password
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Forgot password coming soon')),
          );
        },
        child: Text(
          'Forgot Password?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isLoading = _isLoading || authProvider.isLoading;
        
        return CustomButton(
          text: 'Sign In',
          onPressed: isLoading ? null : _handleSignIn,
          type: ButtonType.primary,
          isLoading: isLoading,
        );
      },
    );
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
          // Navigate to main app
          context.go('/');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'])),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 