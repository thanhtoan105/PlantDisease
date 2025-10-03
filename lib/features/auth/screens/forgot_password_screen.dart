import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/utils/custom_snackbars.dart';
import '../../../navigation/route_names.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGray),
          onPressed: () => context.go(RouteNames.auth),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 48),
              _buildForm(),
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
          'Reset Password',
          style: AppTypography.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email address and we\'ll send you a verification code to reset your password',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.mediumGray,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailField(),
          const SizedBox(height: AppDimensions.spacingXl),
          _buildSendOtpButton(),
          const SizedBox(height: AppDimensions.spacingLg),
          _buildBackToSignInButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email address',
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
        final authProvider = context.read<AuthProvider>();
        if (authProvider.error != null) {
          authProvider.clearError();
        }
      },
    );
  }

  Widget _buildSendOtpButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isLoading = _isLoading || authProvider.isLoading;
        return CustomButton(
          text: 'Send Verification Code',
          onPressed: isLoading ? null : _handleSendOtp,
          type: ButtonType.primary,
          isLoading: isLoading,
        );
      },
    );
  }

  Widget _buildBackToSignInButton() {
    return TextButton(
      onPressed: () => context.go(RouteNames.auth),
      child: Text(
        'Back to Sign In',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();

      // First check if email exists in Supabase authentication
      final emailCheckResult = await authProvider.checkEmailExists(_emailController.text.trim());

      if (emailCheckResult['success']) {
        if (emailCheckResult['exists'] == true) {
          // Email exists, now send reset password email
          final resetResult = await authProvider.resetPassword(_emailController.text.trim());

          if (resetResult['success']) {
            if (mounted) {
              // Navigate to OTP verification screen
              context.go('${RouteNames.verifyOtp}?email=${Uri.encodeComponent(_emailController.text.trim())}');
            }
          } else {
            if (mounted) {
              CustomSnackbars.showError(
                context: context,
                message: resetResult['message'] ?? 'Failed to send verification code',
              );
            }
          }
        } else {
          // Email doesn't exist
          if (mounted) {
            CustomSnackbars.showError(
              context: context,
              message: emailCheckResult['message'] ?? 'Your account has not been created yet!',
            );
          }
        }
      } else {
        // Error checking email
        if (mounted) {
          CustomSnackbars.showError(
            context: context,
            message: emailCheckResult['message'] ?? 'Failed to verify email',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbars.showError(
          context: context,
          message: 'Your account has not been created yet!',
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
