# 🌱 Plant AI Disease Detection App

[![Expo](https://img.shields.io/badge/Built%20with-Expo-000020.svg?style=flat&logo=expo)](https://expo.dev/)
[![React Native](https://img.shields.io/badge/React%20Native-0.79.5-61DAFB.svg?style=flat&logo=react)](https://reactnative.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A sophisticated React Native mobile application that leverages AI technology to detect plant diseases through image analysis, providing farmers and gardening enthusiasts with instant diagnosis and treatment recommendations.

## 📱 Screenshots

> Add your app screenshots here

## ✨ Features

### 🔍 AI-Powered Disease Detection
- **Camera Integration**: Capture plant images using device camera
- **Gallery Upload**: Upload existing photos from device gallery
- **Real-time Analysis**: Instant disease detection using advanced AI algorithms
- **Confidence Scoring**: Reliability metrics for each diagnosis
- **Multiple Disease Detection**: Identify various plant diseases simultaneously

### 🌿 Comprehensive Plant Library
- **Crop Database**: Extensive library of crops and plants
- **Disease Guide**: Detailed information about plant diseases
- **Symptoms Catalog**: Visual and textual symptom descriptions
- **Treatment Recommendations**: Evidence-based treatment suggestions

### 🌤️ Weather Integration
- **Real-time Weather**: Current weather conditions
- **Location-based Forecasts**: GPS-enabled weather data
- **Plant Care Alerts**: Weather-based plant care recommendations
- **Multi-city Support**: Track weather for multiple locations

### 👤 User Experience
- **Intuitive Interface**: Clean, modern UI/UX design
- **Cross-platform**: iOS, Android, and Web support
- **Offline Capability**: Core features work without internet
- **Result History**: Save and track analysis results
- **Profile Management**: Personalized user experience

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v18 or higher) - [Download here](https://nodejs.org/)
- **npm** or **yarn** package manager
- **Expo CLI** - Install globally: `npm install -g @expo/cli`
- **Git** - [Download here](https://git-scm.com/)

### For Mobile Development:
- **Android Studio** (for Android development)
- **Xcode** (for iOS development - macOS only)
- **Expo Go** app on your mobile device

## 🛠️ Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/plant-ai-disease-app.git
cd plant-ai-disease-app
```

### 2. Install Dependencies

```bash
npm install
# or
yarn install
```

### 3. Environment Setup (IMPORTANT!)

**✅ SECURITY UPDATE**: The hardcoded API key has been removed and the app now uses secure environment variables!

#### OpenWeatherMap One Call API 3.0

**🚀 UPGRADED**: This app now uses the advanced One Call API 3.0 with enhanced features:
- 🕐 **46+ years** of historical weather data
- 🤖 **AI-generated weather summaries**
- 📊 **Daily aggregation** and advanced forecasting
- ⚡ **Better performance** and more accurate data

**💰 Pricing**: 1,000 free API calls/day, then £0.0012 per additional call

#### Environment Variables Setup:

1. **Create a `.env` file** in the root directory:
```bash
# Copy the example file
cp env.example .env
```

2. **Add your API keys to `.env`**:
```env
# Weather API Configuration - One Call API 3.0
EXPO_PUBLIC_WEATHER_API_KEY=your_openweather_api_key_here
EXPO_PUBLIC_WEATHER_API_BASE_URL=https://api.openweathermap.org/data/3.0

# AI/ML API Configuration (optional)
EXPO_PUBLIC_AI_MODEL_API_KEY=your_ai_api_key_here
EXPO_PUBLIC_AI_MODEL_BASE_URL=your_ai_service_url_here
```

3. **Get your OpenWeather API Key**:
   - Go to [OpenWeatherMap](https://openweathermap.org/api)
   - Sign up for a free account
   - **Subscribe to One Call API 3.0** (separate subscription required)
   - Navigate to "My API Keys"
   - Copy your API key
   - Replace `your_openweather_api_key_here` in `.env`

**⚠️ IMPORTANT**: One Call API 3.0 requires a separate subscription from the regular weather APIs. Make sure to subscribe to the correct API on the OpenWeatherMap dashboard.

#### Security Features:

✅ **Environment variables** instead of hardcoded keys  
✅ **Error checking** for missing API keys  
✅ **Fallback support** for both API 3.0 and 2.5  
✅ **Proper error handling** and user feedback  

#### For Your Team Members:

**Each team member needs their own API key!** Here's what they should do:

1. **Get their own OpenWeather API key** and subscribe to One Call API 3.0
2. **Create their own `.env` file** with their API key
3. **Never share API keys** in chat or commit them to git

#### Why You Should NOT Hardcode API Keys:
- ❌ **Security Risk**: API keys are visible in source code
- ❌ **Public Exposure**: If repository is public, everyone can see your API key
- ❌ **Cost Risk**: Others might use your API key and consume your quota
- ❌ **Hard to Manage**: Different environments need different keys

### 4. Start Development Server

```bash
npm start
# or
yarn start
# or
npx expo start
```

### 5. Run on Your Device

- **Mobile**: Scan the QR code with Expo Go app
- **iOS Simulator**: Press `i` in the terminal
- **Android Emulator**: Press `a` in the terminal
- **Web**: Press `w` in the terminal

## 📁 Project Structure

```
PlantAIDisease/
├── App.js                 # Main application entry point
├── app.json               # Expo configuration
├── package.json           # Dependencies and scripts
├── .env                   # Environment variables (DO NOT COMMIT)
├── .env.example           # Environment template (COMMIT THIS)
├── assets/                # Static assets (images, icons)
│   ├── icons/
│   │   ├── plant/         # Plant-related icons
│   │   └── weather/       # Weather icons
│   └── *.png              # App icons and images
└── src/
    ├── components/        # Reusable UI components
    │   ├── shared/        # Common components
    │   ├── CropCard.js
    │   ├── DiseaseCard.js
    │   └── WeatherWidget.js
    ├── context/           # React Context providers
    │   └── WeatherContext.js
    ├── navigation/        # Navigation configuration
    │   └── MainNavigator.js
    ├── screens/           # Application screens
    │   ├── AiScanTab.js
    │   ├── CameraScreen.js
    │   ├── CropLibraryScreen.js
    │   ├── DiseaseGuideScreen.js
    │   ├── HomeTab.js
    │   ├── ProfileTab.js
    │   ├── ResultsScreen.js
    │   └── WeatherDetailsScreen.js
    ├── services/          # API and business logic
    │   ├── LocationService.js
    │   ├── PlantDiseaseService.js
    │   └── WeatherApiService.js
    └── theme/             # Design system
        ├── colors.js
        ├── dimensions.js
        ├── typography.js
        └── index.js
```

## 🔧 Development Workflow

### Setting Up Development Environment

#### iOS Development (macOS only)
1. Install **Xcode** from App Store
2. Install **CocoaPods**: `sudo gem install cocoapods`
3. Open iOS Simulator: `npx expo start --ios`

#### Android Development
1. Install **Android Studio**
2. Set up Android SDK and emulator
3. Open Android Emulator: `npx expo start --android`

### Daily Development

```bash
# 1. Pull latest changes
git pull origin main

# 2. Install any new dependencies
npm install

# 3. Start development server
npm start
```

### Making Changes

1. **Create a feature branch**: `git checkout -b feature/your-feature`
2. **Make your changes**
3. **Test on multiple platforms** (iOS, Android, Web)
4. **Commit with meaningful messages**: `git commit -m "feat: add new feature"`
5. **Push and create PR**: `git push origin feature/your-feature`

### Code Style Guidelines

- Use **functional components** and hooks
- Use **meaningful variable names**
- Follow **React Native best practices**
- **Comment complex logic**
- **Test on multiple platforms**

## 🏗️ Building for Production

### Android
```bash
# Build APK
npx expo build:android

# Build AAB (for Google Play)
npx expo build:android -t app-bundle
```

### iOS
```bash
# Build for iOS
npx expo build:ios
```

### Web
```bash
# Build for web
npx expo export:web

# Deploy to hosting service
npx netlify deploy --prod --dir web-build
```

## 🧪 Testing

### Basic Testing
```bash
npm test
```

### Testing Your Setup
1. **Start the app** on your preferred platform
2. **Navigate through tabs**: Home, AI Scan, Profile
3. **Test camera permissions**: Go to AI Scan tab
4. **Test location permissions**: Check weather widget on Home tab

## 🔧 Troubleshooting

### Common Issues

1. **Metro bundler issues**:
   ```bash
   npx expo start --clear
   ```

2. **Node modules issues**:
   ```bash
   rm -rf node_modules
   npm install
   ```

3. **Environment variables not working**:
   - Make sure `.env` file is in root directory
   - Restart development server
   - Check variable names start with `EXPO_PUBLIC_`

4. **API calls failing**:
   - Verify API key is correct in `.env`
   - Check internet connectivity
   - Ensure API key has proper permissions

### Platform-Specific Issues

#### iOS
- Update Xcode to latest version
- Check iOS deployment target compatibility
- Run: `cd ios && pod install`

#### Android
- Update Android SDK and build tools
- Clear build cache: `cd android && ./gradlew clean`
- Ensure emulator is running

## 🤝 Contributing

We welcome contributions! Here's how to get started:

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**
4. **Test thoroughly** on iOS, Android, and Web
5. **Commit your changes**: `git commit -m 'feat: add amazing feature'`
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Code Guidelines

- **Follow ESLint configuration**
- **Use Prettier for formatting**
- **Write meaningful commit messages**
- **Test on multiple platforms**
- **Update documentation if needed**

### Commit Message Format

```
feat: add new disease detection algorithm
fix: resolve camera permission issue
docs: update installation instructions
style: format code with prettier
```

### Before Submitting PR

- [ ] Code follows project style guidelines
- [ ] Tested on iOS, Android, and Web
- [ ] No console errors or warnings
- [ ] Documentation updated if needed
- [ ] All tests pass

## 🐛 Bug Reports

Please use [GitHub Issues](https://github.com/yourusername/plant-ai-disease-app/issues) to report bugs. Include:

- **Device information** (iOS/Android version)
- **Steps to reproduce**
- **Expected vs actual behavior**
- **Screenshots** if applicable
- **Error logs**

## 🚀 GitHub Repository Setup

### Repository Description
> 🌱 AI-powered plant disease detection app built with React Native and Expo. Helps farmers and gardeners identify plant diseases through image analysis, with integrated weather data and comprehensive plant care guides.

### Topics/Tags
```
react-native, expo, plant-disease-detection, ai, machine-learning, 
agriculture, mobile-app, weather-api, camera, cross-platform, 
javascript, plant-care, farming, image-recognition
```

### Repository Setup Steps

1. **Create GitHub repository**
2. **Enable Issues, Projects, Wiki, Discussions**
3. **Set up branch protection** for `main` branch
4. **Add team members** with appropriate permissions
5. **Create issue labels** for better organization

### Team Member Onboarding

**Share with new team members:**

1. **Read this README** completely
2. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/plant-ai-disease-app.git
   cd plant-ai-disease-app
   npm install
   ```
3. **Get your own API keys** (especially OpenWeather API)
4. **Create your `.env` file** with your API keys
5. **Test the setup**: `npm start`
6. **Join team communication** channels

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Expo](https://expo.dev/) for the amazing development platform
- [React Native](https://reactnative.dev/) for cross-platform mobile development
- [OpenWeather API](https://openweathermap.org/api) for weather data
- Plant disease research papers and agricultural databases
- Open source community for various libraries and tools

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/plant-ai-disease-app/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/plant-ai-disease-app/discussions)
- **Email**: your-email@domain.com

## 🗺️ Roadmap

- [ ] Integration with external AI/ML services
- [ ] Advanced disease prediction algorithms
- [ ] Social features (community sharing)
- [ ] Multilingual support
- [ ] IoT sensor integration
- [ ] Professional farmer tools
- [ ] Marketplace integration
- [ ] Advanced analytics dashboard

---

**🎉 Ready to contribute to making agriculture smarter? Clone, setup, and start coding!**

Made with ❤️ by [Your Team Name] 