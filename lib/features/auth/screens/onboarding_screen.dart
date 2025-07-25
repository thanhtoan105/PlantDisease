import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../navigation/route_names.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Health Check',
      subtitle:
          'Take picture of your crop or upload images to detect diseases and receive treatment advice',
      imagePath: 'assets/images/onboarding/news_check.jpg',
      icon: Icons.health_and_safety,
      color: AppColors.primaryGreen,
    ),
    OnboardingData(
      title: 'Community',
      subtitle:
          'Ask a question about your crop to receive help from the community',
      imagePath: 'assets/images/onboarding/farmer_using_smartphone.png',
      icon: Icons.people,
      color: AppColors.accentOrange,
    ),
    OnboardingData(
      title: 'Cultivation Tips',
      subtitle: 'Receive farming advice about how to improve your yield',
      imagePath: 'assets/images/onboarding/cultivation_tips.jpg',
      icon: Icons.agriculture,
      color: AppColors.primaryGreen,
    ),
  ];

  void _handleNext() {
    if (_currentIndex < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // This shouldn't be called anymore since final screen has separate buttons
      _completeOnboardingAndNavigate(RouteNames.auth);
    }
  }

  void _handleSkip() {
    // Complete onboarding and navigate to sign-in screen
    _completeOnboardingAndNavigate(RouteNames.auth);
  }

  void _completeOnboardingAndNavigate(String route) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.completeOnboarding();
    if (mounted) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentIndex < _onboardingData.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  child: TextButton(
                    onPressed: _handleSkip,
                    child: Text(
                      'Skip',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ),
                ),
              ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingXl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image with fallback to icon
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            color: data.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusLarge),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusLarge),
                            child: Image.asset(
                              data.imagePath,
                              width: 300,
                              height: 300,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to icon if image fails to load
                                return Icon(
                                  data.icon,
                                  size: 120,
                                  color: data.color,
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacingXxxl),

                        // Title
                        Text(
                          data.title,
                          style: AppTypography.headlineLarge,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppDimensions.spacingLg),

                        // Subtitle
                        Text(
                          data.subtitle,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.mediumGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page indicators and navigation
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingXl),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppColors.primaryGreen
                              : AppColors.mediumGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXl),

                  // Navigation buttons
                  if (_currentIndex < _onboardingData.length - 1)
                    // Arrow button for non-final screens positioned at bottom right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _handleNext,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    // Sign In and Sign Up buttons for final screen
                    Column(
                      children: [
                        // Sign Up button (primary)
                        CustomButton(
                          text: 'Sign Up',
                          onPressed: () =>
                              _completeOnboardingAndNavigate(RouteNames.signUp),
                          type: ButtonType.primary,
                        ),

                        const SizedBox(height: AppDimensions.spacingLg),

                        // Sign In button (outlined)
                        CustomButton(
                          text: 'Sign In',
                          onPressed: () =>
                              _completeOnboardingAndNavigate(RouteNames.auth),
                          type: ButtonType.secondary,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.icon,
    required this.color,
  });
}
