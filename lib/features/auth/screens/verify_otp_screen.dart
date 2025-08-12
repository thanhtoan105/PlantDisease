import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../navigation/route_names.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  String _otpValue = '';

  @override
  void initState() {
    super.initState();
    // Auto-focus the input when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
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
          onPressed: () => context.go(RouteNames.forgotPassword),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 48),
              _buildOtpInput(),
              const SizedBox(height: AppDimensions.spacingXl),
              _buildButtons(),
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
          'Enter Verification Code',
          style: AppTypography.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve sent a 6-digit verification code to',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.mediumGray,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          widget.email,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      children: [
        // Visual representation of OTP boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildOtpBox(index)),
        ),
        const SizedBox(height: 16),
        // Hidden text field that captures the actual input
        Container(
          width: 0.1,
          height: 0.1,
          child: TextField(
            controller: _otpController,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            style: const TextStyle(color: Colors.transparent),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              setState(() {
                _otpValue = value;
              });
            },
            onSubmitted: (value) {
              if (value.length == 6) {
                _handleVerifyOtp();
              }
            },
          ),
        ),
        // Tap area to focus the hidden input
        GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
          },
          child: Container(
            width: double.infinity,
            height: 60,
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    bool hasValue = index < _otpValue.length;
    bool isCurrent = index == _otpValue.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(
          color: hasValue
              ? AppColors.primaryGreen
              : isCurrent
                  ? AppColors.primaryGreen.withOpacity(0.5)
                  : AppColors.lightGray,
          width: hasValue || isCurrent ? 2 : 1,
        ),
        boxShadow: (hasValue || isCurrent)
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: hasValue
            ? Text(
                _otpValue[index],
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.bold,
                ),
              )
            : isCurrent
                ? Container(
                    width: 2,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  )
                : null,
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        CustomButton(
          text: 'Verify',
          onPressed: _isOtpComplete() && !_isLoading ? _handleVerifyOtp : null,
          type: ButtonType.primary,
          isLoading: _isLoading,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        CustomButton(
          text: 'Cancel',
          onPressed: _isLoading ? null : () => context.go(RouteNames.auth),
          type: ButtonType.secondary,
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        _buildResendCode(),
      ],
    );
  }

  Widget _buildResendCode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code? ",
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.mediumGray,
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _handleResendCode,
          child: Text(
            'Resend',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  bool _isOtpComplete() {
    return _otpValue.length == 6;
  }

  String _getOtpCode() {
    return _otpValue;
  }

  Future<void> _handleVerifyOtp() async {
    if (!_isOtpComplete()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Use Supabase's verifyOTP method for password recovery with correct syntax
      final AuthResponse response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.recovery,
        token: _getOtpCode(),
        email: widget.email,
      );

      // Check if verification was successful
      if (response.user != null && response.session != null) {
        if (mounted) {
          // OTP verified successfully - redirect to reset password screen
          context.go('${RouteNames.resetPassword}?email=${Uri.encodeComponent(widget.email)}');
        }
      } else {
        throw Exception('Verification failed');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Invalid verification code. Please try again.';

        // Provide more specific error messages
        String errorString = e.toString().toLowerCase();
        if (errorString.contains('expired') || errorString.contains('otp_expired')) {
          errorMessage = 'Verification code has expired. Please request a new one.';
        } else if (errorString.contains('invalid') || errorString.contains('token_hash_not_found')) {
          errorMessage = 'Invalid verification code. Please check and try again.';
        } else if (errorString.contains('too_many_requests')) {
          errorMessage = 'Too many attempts. Please wait before trying again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
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

  Future<void> _handleResendCode() async {
    // Clear the OTP input
    setState(() {
      _otpValue = '';
      _otpController.clear();
    });

    // Focus on the input field
    _focusNode.requestFocus();

    // Show resend message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification code resent to your email'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
