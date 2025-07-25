# Task Completion Checklist

## Before Committing Code

### 1. Code Quality Checks
- [ ] Run `flutter analyze` to check for static analysis issues
- [ ] Run `flutter format .` to ensure consistent code formatting
- [ ] Verify no linting errors in IDE
- [ ] Check that all imports are properly organized

### 2. Testing
- [ ] Run `flutter test` to ensure all tests pass
- [ ] Test on both Android and iOS if possible
- [ ] Verify app builds successfully: `flutter build apk --debug`
- [ ] Test critical user flows manually

### 3. Environment & Configuration
- [ ] Ensure `.env` file is properly configured (not committed)
- [ ] Verify Supabase connection works
- [ ] Test TensorFlow model loading and inference
- [ ] Check weather API integration

### 4. Dependencies
- [ ] Run `flutter pub get` after any dependency changes
- [ ] Check for security vulnerabilities: `flutter pub deps`
- [ ] Verify no unused dependencies

### 5. Documentation
- [ ] Update relevant README files if needed
- [ ] Add/update code comments for complex logic
- [ ] Document any new environment variables in `.env.example`

### 6. Performance
- [ ] Check app startup time
- [ ] Verify memory usage is reasonable
- [ ] Test camera and AI inference performance
- [ ] Ensure smooth UI interactions

### 7. Platform-Specific
- [ ] Test on different Android API levels (min SDK)
- [ ] Verify permissions work correctly (camera, location)
- [ ] Check app icons and splash screens

## Pre-Release Checklist
- [ ] Update version in `pubspec.yaml`
- [ ] Test release build: `flutter build apk --release`
- [ ] Verify all production API keys are configured
- [ ] Test on physical devices
- [ ] Performance testing with release build