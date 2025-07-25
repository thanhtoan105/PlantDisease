# Environment Setup and Configuration

## Required Environment Variables
Create a `.env` file based on `.env.example`:

```bash
# Weather API Configuration
WEATHER_API_KEY=your_openweathermap_api_key_here
WEATHER_API_BASE_URL=https://api.openweathermap.org/data/2.5

# Supabase Configuration  
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

## External Service Setup

### 1. OpenWeatherMap API
- Sign up at https://openweathermap.org/api
- Get your API key
- Add to `.env` file as `WEATHER_API_KEY`

### 2. Supabase Setup
- Create project at https://supabase.com/dashboard
- Get project URL and anon key from settings
- Configure custom schema: `plant_disease`
- Add credentials to `.env` file

### 3. TensorFlow Model
- Model file: `assets/models/apple_model_final.tflite`
- Labels file: `assets/models/labels.txt`
- Input size: 128x128x3 RGB images
- Output: Probability scores for 4 classes

## Development Environment
- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: Included with Flutter
- **Android Studio**: For Android development
- **Xcode**: For iOS development (macOS only)
- **VS Code**: Recommended editor with Flutter extension

## Platform Requirements
- **Android**: Min SDK 21, Target SDK latest
- **iOS**: iOS 12.0+ (if building for iOS)
- **NDK Version**: 27.0.12077973 (for Android)

## Permissions Required
- Camera access (for plant photo capture)
- Location access (for weather data)
- Internet access (for API calls)
- Storage access (for saving images)

## Build Configuration
- **Package Name**: com.example.plant_ai_disease_flutter
- **Version**: 1.0.0+1
- **Material 3**: Enabled
- **Null Safety**: Enabled