class RouteNames {
  // Auth routes
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';
  static const String resetPassword = '/reset-password';

  // Main routes
  static const String main = '/main';
  static const String home = '/home';
  static const String aiScan = '/ai-scan';
  static const String profile = '/profile';

  // Home stack routes
  static const String cropLibrary = '/crop-library';
  static const String cropDetails = '/crop-details';
  static const String diseaseDetail = '/disease-detail';
  static const String weatherDetails = '/weather-details';
  static const String search = '/search';

  // AI Scan stack routes
  static const String camera = '/camera';
  static const String results = '/results';
  static const String test = '/test';

  // Profile stack routes
  static const String profileDetails = '/profile-details';
  static const String editProfile = '/edit-profile';
  static const String databaseSetup = '/database-setup';
  static const String databaseTest = '/database-test';

  // Private constructor to prevent instantiation
  RouteNames._();
}
