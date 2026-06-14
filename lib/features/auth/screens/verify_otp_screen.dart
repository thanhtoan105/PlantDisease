import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/utils/custom_snackbars.dart';
import '../../../navigation/route_names.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen>
    with WidgetsBindingObserver {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  String _otpValue = '';

  @override
  void initState() {
    super.initState();
    // Add lifecycle observer to detect app state changes
    WidgetsBinding.instance.addObserver(this);
    // Auto-focus the input when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app resumes from background, restore keyboard focus
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });
    }
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
      body: GestureDetector(
        // Tap anywhere to show keyboard
        onTap: () => _focusNode.requestFocus(),
        child: SafeArea(
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: PinCodeTextField(
        appContext: context,
        length: 6,
        controller: _otpController,
        focusNode: _focusNode,
        autoFocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        enableActiveFill: true,
        autoDisposeControllers: false,
        animationType: AnimationType.fade,
        animationDuration: const Duration(milliseconds: 200),
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          fieldHeight: 60,
          fieldWidth: 50,
          activeFillColor: AppColors.white,
          selectedFillColor: AppColors.white,
          inactiveFillColor: AppColors.white,
          activeColor: AppColors.primaryGreen,
          selectedColor: AppColors.primaryGreen,
          inactiveColor: AppColors.lightGray,
          borderWidth: 2,
          activeBorderWidth: 2,
          selectedBorderWidth: 2,
          inactiveBorderWidth: 1,
        ),
        textStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.darkGray,
          fontWeight: FontWeight.bold,
        ),
        cursorColor: AppColors.primaryGreen,
        cursorHeight: 24,
        onChanged: (value) {
          setState(() {
            _otpValue = value;
          });
        },
        onCompleted: (value) {
          if (value.length == 6) {
            _handleVerifyOtp();
          }
        },
        beforeTextPaste: (text) {
          // Allow pasting only if it's 6 digits
          return text?.length == 6 && RegExp(r'^\d+$').hasMatch(text ?? '');
        },
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
      final AuthResponse response =
          await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.recovery,
        token: _getOtpCode(),
        email: widget.email,
      );

      // Check if verification was successful
      if (response.user != null && response.session != null) {
        if (mounted) {
          // OTP verified successfully - redirect to reset password screen
          context.go(
              '${RouteNames.resetPassword}?email=${Uri.encodeComponent(widget.email)}');
        }
      } else {
        throw Exception('Verification failed');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Invalid verification code. Please try again.';

        // Provide more specific error messages
        String errorString = e.toString().toLowerCase();
        if (errorString.contains('expired') ||
            errorString.contains('otp_expired')) {
          errorMessage =
              'Verification code has expired. Please request a new one.';
        } else if (errorString.contains('invalid') ||
            errorString.contains('token_hash_not_found')) {
          errorMessage =
              'Invalid verification code. Please check and try again.';
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
    setState(() {
      _isLoading = true;
    });

    try {
      // Actually resend the OTP via Supabase
      await Supabase.instance.client.auth.resetPasswordForEmail(
        widget.email,
      );

      // Clear the OTP input
      setState(() {
        _otpValue = '';
        _otpController.clear();
      });

      // Focus on the input field
      _focusNode.requestFocus();

      if (mounted) {
        CustomSnackbars.showSuccess(
          context: context,
          message: 'Verification code resent to your email',
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage =
            'Failed to resend code. Please try again after 60 seconds.';
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
}
