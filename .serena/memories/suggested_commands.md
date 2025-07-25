# Suggested Commands for Development

## Flutter Development Commands

### Basic Development
```bash
# Get dependencies
flutter pub get

# Run the app in debug mode
flutter run

# Run on specific device
flutter run -d <device-id>

# Hot reload (during development)
r

# Hot restart (during development)
R

# Quit app (during development)
q
```

### Code Quality & Analysis
```bash
# Run static analysis
flutter analyze

# Format code
flutter format .

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Build Commands
```bash
# Build APK for Android
flutter build apk

# Build app bundle for Android
flutter build appbundle

# Build for iOS (macOS only)
flutter build ios

# Build for release
flutter build apk --release
```

### Device & Debugging
```bash
# List connected devices
flutter devices

# Clean build cache
flutter clean

# Check Flutter installation
flutter doctor

# Check for dependency updates
flutter pub outdated
```

## Environment Setup
```bash
# Copy environment template
copy .env.example .env

# Edit environment variables (Windows)
notepad .env
```

## Windows-Specific Commands
```bash
# List files
dir

# Change directory
cd <directory>

# Find files
where <filename>

# Search in files
findstr "pattern" *.dart
```

## Serena Integration
```bash
# Start Serena server (if configured)
uvx --from git+https://github.com/oraios/serena serena-mcp-server --project . --context ide-assistant
```