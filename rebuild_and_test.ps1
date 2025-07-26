Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Flutter Plant Disease Detection App" -ForegroundColor Cyan
Write-Host "Rebuild and Test Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Step 1: Cleaning Flutter build cache..." -ForegroundColor Yellow
flutter clean

Write-Host ""
Write-Host "Step 2: Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "Step 3: Checking if model file exists..." -ForegroundColor Yellow
$modelFile = "assets\models\apple_model_final.tflite"
if (Test-Path $modelFile) {
    $fileSize = (Get-Item $modelFile).Length
    Write-Host "✅ Model file found: $modelFile" -ForegroundColor Green
    Write-Host "   File size: $fileSize bytes" -ForegroundColor Green
} else {
    Write-Host "❌ Model file NOT found: $modelFile" -ForegroundColor Red
    Write-Host "Please ensure the model file is in the correct location." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Step 4: Checking if labels file exists..." -ForegroundColor Yellow
$labelsFile = "assets\models\labels.txt"
if (Test-Path $labelsFile) {
    Write-Host "✅ Labels file found: $labelsFile" -ForegroundColor Green
} else {
    Write-Host "❌ Labels file NOT found: $labelsFile" -ForegroundColor Red
}

Write-Host ""
Write-Host "Step 5: Verifying pubspec.yaml assets configuration..." -ForegroundColor Yellow
$pubspecContent = Get-Content "pubspec.yaml" -Raw
if ($pubspecContent -match "assets/models/") {
    Write-Host "✅ Assets configuration found in pubspec.yaml" -ForegroundColor Green
} else {
    Write-Host "❌ Assets configuration missing in pubspec.yaml" -ForegroundColor Red
}

Write-Host ""
Write-Host "Step 6: Building APK in debug mode..." -ForegroundColor Yellow
$buildResult = flutter build apk --debug
$buildExitCode = $LASTEXITCODE

if ($buildExitCode -eq 0) {
    Write-Host "✅ Build successful!" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Step 7: Installing APK to connected device..." -ForegroundColor Yellow
    $installResult = flutter install
    $installExitCode = $LASTEXITCODE
    
    if ($installExitCode -eq 0) {
        Write-Host "✅ Installation successful!" -ForegroundColor Green
        Write-Host ""
        Write-Host "The app has been rebuilt and installed." -ForegroundColor Green
        Write-Host "Please test the AI scan functionality now." -ForegroundColor Green
        Write-Host "Check the debug console for detailed logs about model loading." -ForegroundColor Green
    } else {
        Write-Host "❌ Installation failed. Please check if a device is connected." -ForegroundColor Red
    }
} else {
    Write-Host "❌ Build failed. Please check the error messages above." -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Script completed. Press any key to exit." -ForegroundColor Cyan
Read-Host
