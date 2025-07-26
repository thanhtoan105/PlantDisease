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
  final String? initialTab;

  const AuthScreen({super.key, this.initialTab});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  late String _activeTab;
  bool _showPassword = false;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    // Default to signin if onboarding is completed, signup for new users
    final authProvider = context.read<AuthProvider>();
    _activeTab = widget.initialTab ??
        (authProvider.onboardingCompleted ? 'signin' : 'signup');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _handleInputChange() {
    // Clear errors when user starts typing
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();
  }

  void _switchTab(String newTab) {
    setState(() {
      _activeTab = newTab;
    });
    // Clear errors when switching tabs
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();
  }

  bool _validateForm() {
    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your email');
      return false;
    }

    if (!_emailController.text.contains('@')) {
      _showErrorDialog('Please enter a valid email address');
      return false;
    }

    if (_passwordController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your password');
      return false;
    }

    if (_activeTab == 'signup') {
      if (_passwordController.text.length < 6) {
        _showErrorDialog('Password must be at least 6 characters long');
        return false;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        _showErrorDialog('Passwords do not match');
        return false;
      }

      if (!_agreeToTerms) {
        _showErrorDialog('Please agree to the Terms and Policies');
        return false;
      }
    }

    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    final authProvider = context.read<AuthProvider>();

    try {
      Map<String, dynamic> result;

      if (_activeTab == 'signup') {
        result = await authProvider.signUp(
          _emailController.text.trim(),
          _passwordController.text,
          userData: {
            'username': _usernameController.text.trim().isEmpty
                ? _emailController.text.split('@')[0]
                : _usernameController.text.trim(),
          },
        );
      } else {
        result = await authProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }

      if (mounted) {
        if (result['success']) {
          if (_activeTab == 'signup') {
            _showSuccessDialog(result['message']);
          }
          // Navigation will be handled automatically by AuthProvider
        } else {
          _showErrorDialog(result['error']);
        }
      }
    } catch (error) {
      if (mounted) {
        _showErrorDialog(error.toString());
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your email address first');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final result =
        await authProvider.resetPassword(_emailController.text.trim());

    if (mounted) {
      if (result['success']) {
        _showSuccessDialog(result['message']);
      } else {
        _showErrorDialog(result['error']);
      }
    }
  }

  Future<void> _handleSkipAuth() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Continue as Guest'),
        content: const Text(
          'You can sign up later to save your data and access all features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final router = GoRouter.of(context);
              navigator.pop();
              final authProvider = context.read<AuthProvider>();
              await authProvider.skipAuth();
              if (mounted) {
                router.go(RouteNames.main);
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Container(
            height: 150,
            margin: const EdgeInsets.only(bottom: AppDimensions.spacingXxxl),
            child: Image.asset(
              'assets/images/onboarding/farmer_using_smartphone.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMedium),
                  ),
                  child: const Icon(
                    Icons.person_add,
                    size: 64,
                    color: AppColors.mediumGray,
                  ),
                );
              },
            ),
          ),

          Text(
            'Sign up',
            style: AppTypography.headlineLarge.copyWith(fontSize: 28),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.spacingSm),

          Text(
            'Create a new account to continue',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.spacingXxxl),

          // Email field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your email Id',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                onChanged: (_) => _handleInputChange(),
                decoration: const InputDecoration(
                  hintText: 'example@domain.com',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // Username field (optional)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Username (optional)',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              TextFormField(
                controller: _usernameController,
                onChanged: (_) => _handleInputChange(),
                decoration: const InputDecoration(
                  hintText: 'Enter username',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // Password field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create password',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                onChanged: (_) => _handleInputChange(),
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.mediumGray,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // Confirm password field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm password',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showPassword,
                onChanged: (_) => _handleInputChange(),
                decoration: const InputDecoration(
                  hintText: 'Confirm password',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // Terms checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
                activeColor: AppColors.primaryGreen,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _agreeToTerms = !_agreeToTerms;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.bodyMedium,
                        children: [
                          const TextSpan(text: 'By ticking you agree to our '),
                          TextSpan(
                            text: 'Terms and Policies',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // Sign up button
          CustomButton(
            text: 'Sign up',
            onPressed: _handleSubmit,
            type: ButtonType.primary,
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // Switch to sign in
          Center(
            child: GestureDetector(
              onTap: () => _switchTab('signin'),
              child: RichText(
                text: TextSpan(
                  style: AppTypography.bodyMedium,
                  children: [
                    const TextSpan(text: 'Already have an Account? '),
                    TextSpan(
                      text: 'Log in',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXl),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.darkNavy),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            context.go(RouteNames.onboarding);
                          }
                        },
                      ),
                      TextButton(
                        onPressed: _handleSkipAuth,
                        child: Text(
                          'Skip',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Error display
                if (authProvider.error != null)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingXl,
                      vertical: AppDimensions.spacingSm,
                    ),
                    padding: const EdgeInsets.all(AppDimensions.spacingLg),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE6E6),
                      borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusSmall),
                    ),
                    child: Text(
                      authProvider.error!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Form content
                Expanded(
                  child: authProvider.isLoading
                      ? const Center(
                          child: LoadingSpinner(message: 'Please wait...'),
                        )
                      : Form(
                          key: _formKey,
                          child: _activeTab == 'signup'
                              ? _buildSignUpForm()
                              : _buildSignInForm(),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Container(
            height: 150,
            margin: const EdgeInsets.only(bottom: AppDimensions.spacingXxxl),
            child: Image.asset(
              'assets/images/onboarding/news_check.jpg',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusMedium),
                  ),
                  child: const Icon(
                    Icons.login,
                    size: 64,
                    color: AppColors.mediumGray,
                  ),
                );
              },
            ),
          ),

          Text(
            'Welcome Back !',
            style: AppTypography.headlineLarge.copyWith(fontSize: 28),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.spacingSm),

          Text(
            'Log in to Continue',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppDimensions.spacingXxxl),

          // Email field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your email ID/phone number',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                onChanged: (_) => _handleInputChange(),
                decoration: const InputDecoration(
                  hintText: 'example@domain.com',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // Password field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your password',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.darkNavy,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                onChanged: (_) => _handleInputChange(),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.mediumGray,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _handleForgotPassword,
              child: Text(
                'Forgot password ?',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // Log in button
          CustomButton(
            text: 'Log in',
            onPressed: _handleSubmit,
            type: ButtonType.primary,
          ),

          const SizedBox(height: AppDimensions.spacingXl),

          // Switch to sign up
          Center(
            child: GestureDetector(
              onTap: () => _switchTab('signup'),
              child: RichText(
                text: TextSpan(
                  style: AppTypography.bodyMedium,
                  children: [
                    const TextSpan(text: 'Don\'t have Account? '),
                    TextSpan(
                      text: 'Sign up',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXl),
        ],
      ),
    );
  }
}
