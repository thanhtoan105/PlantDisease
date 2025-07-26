# TensorFlow Lite Model Loading Fix Guide

## Problem
The app shows "Demo Mode: AI model file not found. Showing simulated results" even though the model file exists in the assets folder.

## Root Cause
The issue is likely that the app is running from an old build where the assets weren't properly included in the APK, or there's a caching issue preventing the new assets from being loaded.

## Solution Steps

### Step 1: Verify Model File Exists
1. Check that `assets/models/apple_model_final.tflite` exists and has a reasonable size (should be > 1MB)
2. Check that `assets/models/labels.txt` exists and contains the class labels

### Step 2: Clean and Rebuild
The most important step is to completely clean and rebuild the app:

#### Option A: Using the provided scripts
1. Run `rebuild_and_test.bat` (Windows Command Prompt) or `rebuild_and_test.ps1` (PowerShell)
2. These scripts will:
   - Clean the Flutter build cache
   - Verify model files exist
   - Rebuild the APK
   - Install to connected device

#### Option B: Manual steps
```bash
# Clean Flutter cache
flutter clean

# Get dependencies
flutter pub get

# Build and install
flutter build apk --debug
flutter install
```

### Step 3: Check Debug Logs
After rebuilding and installing:

1. Connect your device to your computer
2. Run `flutter logs` or `adb logcat` to see debug output
3. Look for these log messages when you open the AI scan screen:
   - `🔍 Checking asset availability...`
   - `✅ Model file found: [size] bytes` (success)
   - `❌ Model file not found: [error]` (failure)

### Step 4: Verify Asset Manifest
The enhanced debug code will now show:
- Whether the model file can be loaded
- The file size if found
- What assets are available in the app bundle
- Whether the model is listed in the asset manifest

## Expected Debug Output (Success)
```
🔍 Checking asset availability...
✅ Model file found: 2847392 bytes
✅ Labels file found: 65 characters
📋 Labels: Apple___Apple_scab, Apple___Black_rot, Apple___Cedar_apple_rust, Apple___healthy
🔍 Model assets in manifest: [assets/models/apple_model_final.tflite]
🔍 All model assets: [assets/models/apple_model_final.tflite, assets/models/labels.txt, assets/models/README.md]
🔬 Initializing TensorFlow Lite model...
📊 Model file found, size: 2847392 bytes
✅ Model file validation passed
✅ Interpreter created with CPU only
✅ TensorFlow model loaded successfully
```

## Expected Debug Output (Failure)
```
🔍 Checking asset availability...
❌ Model file not found: [error details]
🔍 Error details: [specific error]
🔍 Model assets in manifest: []
🔍 All model assets: [assets/models/labels.txt, assets/models/README.md]
```

## Troubleshooting

### If model file is not found in manifest:
1. Check `pubspec.yaml` has `- assets/models/` in the assets section
2. Ensure you've run `flutter clean` and `flutter pub get`
3. Rebuild the app completely

### If model file exists but can't be loaded:
1. Check file permissions
2. Verify the file isn't corrupted (should be ~2.8MB for the apple model)
3. Try copying the model file again from the source

### If build fails:
1. Check Flutter version: `flutter --version`
2. Check for any dependency conflicts: `flutter pub deps`
3. Try `flutter pub cache repair`

## Model File Requirements
- **File**: `assets/models/apple_model_final.tflite`
- **Size**: Should be around 2.8MB
- **Format**: TensorFlow Lite (.tflite)
- **Input**: 128x128x3 RGB images
- **Output**: 4 classes (Apple scab, Black rot, Cedar apple rust, Healthy)

## Testing the Fix
1. Rebuild and install the app using the provided scripts
2. Open the AI scan screen
3. Check debug logs for successful model loading
4. Try taking a photo - should show actual AI analysis instead of demo mode
5. The demo mode banner should disappear

## Additional Notes
- The app will still work in demo mode if the model fails to load
- Demo mode provides simulated results for testing UI functionality
- Real AI analysis requires the actual TensorFlow Lite model file
- The model file must be properly bundled in the APK during build time
