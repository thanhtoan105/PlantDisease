# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- Install dependencies: `flutter pub get`
- Run the app: `flutter run`
- Run on a specific device: `flutter run -d <device-id>`
- List devices: `flutter devices`
- Static analysis: `flutter analyze`
- Format Dart code: `dart format .` or `flutter format .`
- Run all tests: `flutter test`
- Run a single test file: `flutter test test/<file>_test.dart`
- Run a single test by name: `flutter test --name "<test name>"`
- Build Android APK: `flutter build apk --release`
- Build Android App Bundle: `flutter build appbundle --release`
- Build iOS release on macOS: `flutter build ios --release`
- Clean generated/build artifacts: `flutter clean`
- Check local Flutter setup: `flutter doctor`

There are currently no Dart test files under `test/`; add tests there before relying on `flutter test` for coverage.

## Environment and assets

- Copy `.env.example` to `.env` before running locally.
- Required environment variables are loaded by `EnvConfig` from `.env`: `WEATHER_API_KEY`, `WEATHER_API_BASE_URL`, `SUPABASE_URL`, and `SUPABASE_ANON_KEY`.
- `pubspec.yaml` includes `.env`, `assets/images/`, `assets/images/onboarding/`, `assets/icons/`, and `assets/models/` as Flutter assets.
- TensorFlow Lite configuration lives in `lib/core/config/ai_model_config.dart`. The app expects `assets/models/tomato_model_final.tflite` and `assets/models/labels.txt`.

## High-level architecture

This is a Flutter app for plant disease detection. It uses Provider for state management, GoRouter for navigation, Supabase for auth/database/storage, OpenWeatherMap for weather, and TensorFlow Lite for on-device image classification.

### App startup

- `lib/main.dart` initializes Flutter bindings, loads `.env`, locks orientation to portrait, initializes Supabase with the custom `plant_disease` PostgREST schema, starts diagnostics, and registers top-level providers.
- `lib/app.dart` builds `MaterialApp.router` with `AppTheme.lightTheme` and `AppRouter.router`. It also registers `AuthProvider` and `ScanHistoryProvider`, so note that `AuthProvider` is created both in `main.dart` and `app.dart`.

### Routing and screen flow

- Routes are defined in `lib/navigation/app_router.dart`; route constants are in `lib/navigation/route_names.dart`.
- The router redirect depends on `AuthProvider`: wait for initialization, allow password reset/OTP routes, require onboarding completion, then require authentication.
- `lib/features/main/main_screen.dart` is the authenticated shell. It uses an `IndexedStack` with three bottom tabs: Home, Scan, and Profile.
- Feature screens live under `lib/features/auth`, `lib/features/home`, `lib/features/ai_scan`, `lib/features/profile`, and `lib/features/main`.

### State and services

- Providers live in `lib/core/providers/` and expose UI state through `ChangeNotifier`.
  - `AuthProvider` handles Supabase auth state, onboarding flags in `SharedPreferences`, sign-in/sign-up/reset flows, and auth listener updates.
  - `PlantProvider` loads crops and crop details through `PlantService`.
  - `WeatherProvider` coordinates weather/location state through `WeatherService`.
  - `ScanHistoryProvider` loads user scan history from Supabase into `ScanHistory` models.
- Service classes live in `lib/core/services/` and are mostly static facades.
  - `SupabaseService` owns crop/disease queries, RPC searches, scan image upload to the `scan-images` storage bucket, analysis result inserts, scan history reads, and profile reads.
  - `PlantService` wraps plant/crop operations and returns `{success, data}` maps for providers.
  - `WeatherService` uses `http`, `geolocator`, and `geocoding` for location, OpenWeatherMap One Call data, forecasts, city search, and mock fallback data.
  - `TensorFlowService` loads the TFLite interpreter, labels, CPU/GPU delegate options, preprocesses images to `AIModelConfig.inputImageSize`, runs inference, and returns normalized prediction maps. If model loading fails, it can return demo fallback results so the app can continue.
  - `CameraService` handles camera/image acquisition for scan flows.

### Data shape and backend assumptions

- Supabase is initialized against schema `plant_disease` in `main.dart`.
- Crop/disease queries assume tables/functions including `crops`, `diseases`, `analysis_results`, `profiles`, `search_crops`, and `search_diseases`.
- Scan persistence uploads images to Supabase Storage bucket `scan-images`, then inserts `detected_diseases`, `location_data`, and `analysis_date` into `analysis_results`.
- Crop descriptions may be JSONB. `SupabaseService` contains helper extraction logic for `overview.description`, `legacy_description`, and direct `description` keys.

### UI conventions

- Theme primitives are centralized in `lib/core/theme/` (`app_theme.dart`, `app_colors.dart`, `app_dimensions.dart`, `app_typography.dart`).
- Reusable widgets live in `lib/shared/widgets/`.
- Feature-specific widgets stay under their feature directory, such as `lib/features/home/widgets/` and `lib/features/profile/widgets/`.

## Project notes

- `analysis_options.yaml` uses `package:flutter_lints/flutter.yaml`.
- No `CLAUDE.md`, Cursor rules, or Copilot instructions existed before this file was created.
- README mentions a `supabase_setup.sql` setup script, but no root-level `.sql` file is currently present in this repository.
