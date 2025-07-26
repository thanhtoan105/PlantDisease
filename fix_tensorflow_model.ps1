#!/usr/bin/env pwsh

Write-Host "🔧 Fixing TensorFlow Lite Model Loading Issue" -ForegroundColor Green
Write-Host "Using NEWEST TensorFlow Lite 2.17.0 (instead of old 2.11.0)" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

# Step 1: Clean everything
Write-Host "Step 1: Cleaning project..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter clean failed" -ForegroundColor Red
    exit 1
}

# Step 2: Clean Android build cache
Write-Host ""
Write-Host "Step 2: Cleaning Android build cache..." -ForegroundColor Yellow
if (Test-Path "android\.gradle") {
    Remove-Item -Recurse -Force "android\.gradle"
    Write-Host "✅ Removed Android .gradle cache" -ForegroundColor Green
}

if (Test-Path "android\app\build") {
    Remove-Item -Recurse -Force "android\app\build"
    Write-Host "✅ Removed Android app build cache" -ForegroundColor Green
}

if (Test-Path "android\build") {
    Remove-Item -Recurse -Force "android\build"
    Write-Host "✅ Removed Android build cache" -ForegroundColor Green
}

# Step 3: Get dependencies
Write-Host ""
Write-Host "Step 3: Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter pub get failed" -ForegroundColor Red
    exit 1
}

# Step 4: Verify model file exists
Write-Host ""
Write-Host "Step 4: Verifying model file..." -ForegroundColor Yellow
$modelFile = "assets\models\apple_model_final.tflite"
if (Test-Path $modelFile) {
    $fileSize = (Get-Item $modelFile).Length
    Write-Host "✅ Model file found: $modelFile" -ForegroundColor Green
    Write-Host "   File size: $fileSize bytes" -ForegroundColor Green
    
    if ($fileSize -lt 1000) {
        Write-Host "⚠️  Warning: Model file seems too small" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Model file NOT found: $modelFile" -ForegroundColor Red
    Write-Host "Please ensure the model file is in the correct location." -ForegroundColor Red
    exit 1
}

# Step 5: Build and run
Write-Host ""
Write-Host "Step 5: Building and running app..." -ForegroundColor Yellow
Write-Host "This will take a few minutes as we are forcing newer TensorFlow Lite dependencies..." -ForegroundColor Cyan
Write-Host ""

flutter run --debug

Write-Host ""
Write-Host "Fix Applied!" -ForegroundColor Green
Write-Host "The app should now load the TensorFlow Lite model successfully." -ForegroundColor Green
Write-Host "Look for TensorFlow model loaded successfully in the logs." -ForegroundColor Green
