@echo off
echo ========================================
echo Flutter Plant Disease Detection App
echo Rebuild and Test Script
echo ========================================

echo.
echo Step 1: Cleaning Flutter build cache...
flutter clean

echo.
echo Step 2: Getting Flutter dependencies...
flutter pub get

echo.
echo Step 3: Checking if model file exists...
if exist "assets\models\apple_model_final.tflite" (
    echo ✅ Model file found: assets\models\apple_model_final.tflite
    for %%A in ("assets\models\apple_model_final.tflite") do echo    File size: %%~zA bytes
) else (
    echo ❌ Model file NOT found: assets\models\apple_model_final.tflite
    echo Please ensure the model file is in the correct location.
    pause
    exit /b 1
)

echo.
echo Step 4: Checking if labels file exists...
if exist "assets\models\labels.txt" (
    echo ✅ Labels file found: assets\models\labels.txt
) else (
    echo ❌ Labels file NOT found: assets\models\labels.txt
)

echo.
echo Step 5: Building APK in debug mode...
flutter build apk --debug

if %ERRORLEVEL% EQU 0 (
    echo ✅ Build successful!
    echo.
    echo Step 6: Installing APK to connected device...
    flutter install
    
    if %ERRORLEVEL% EQU 0 (
        echo ✅ Installation successful!
        echo.
        echo The app has been rebuilt and installed.
        echo Please test the AI scan functionality now.
        echo Check the debug console for detailed logs about model loading.
    ) else (
        echo ❌ Installation failed. Please check if a device is connected.
    )
) else (
    echo ❌ Build failed. Please check the error messages above.
)

echo.
echo ========================================
echo Script completed. Press any key to exit.
pause
