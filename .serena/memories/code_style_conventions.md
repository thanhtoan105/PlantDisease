# Code Style and Conventions

## Dart/Flutter Conventions
- **Linting**: Uses `flutter_lints` package with standard Flutter rules
- **Analysis**: Configured via `analysis_options.yaml` with `package:flutter_lints/flutter.yaml`
- **Naming**: 
  - Classes: PascalCase (e.g., `PlantDiseaseApp`, `TensorFlowService`)
  - Files: snake_case (e.g., `app_theme.dart`, `tensorflow_service.dart`)
  - Variables/methods: camelCase
  - Constants: camelCase with static const

## Architecture Patterns
- **Feature-based structure**: Organized by features (auth, home, ai_scan, profile)
- **Provider pattern**: For state management
- **Service layer**: Separate services for different concerns (camera, tensorflow, weather, supabase)
- **Shared widgets**: Reusable UI components in `shared/widgets`

## File Organization
```
lib/
├── core/           # Core functionality (config, providers, services, theme, utils)
├── features/       # Feature modules (auth, home, ai_scan, profile, etc.)
├── navigation/     # Routing configuration
├── shared/         # Shared widgets and utilities
├── app.dart        # Main app widget
└── main.dart       # Entry point
```

## Documentation
- Classes and methods use triple-slash comments (`///`)
- Services include detailed documentation for public methods
- README files in asset directories explain usage

## Code Quality
- Material 3 design system
- Null safety enabled
- Environment variables managed through .env files
- Error handling with try-catch blocks and debug prints