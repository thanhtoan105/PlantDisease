# Architecture Overview

## Application Architecture

### State Management
- **Provider Pattern**: Used throughout the app
- **Key Providers**:
  - `AuthProvider`: User authentication state
  - `WeatherProvider`: Weather data management  
  - `PlantProvider`: Plant and disease data

### Navigation
- **GoRouter**: Declarative routing system
- **Route Configuration**: Centralized in `navigation/app_router.dart`
- **Route Names**: Defined in `navigation/route_names.dart`

### Service Layer
Core services handle different aspects of the application:

- **`TensorFlowService`**: AI model loading and inference
- **`CameraService`**: Camera operations and image capture
- **`SupabaseService`**: Database operations and authentication
- **`WeatherService`**: Weather API integration
- **`PlantService`**: Plant and disease data management

### Feature Modules
Each feature is self-contained with its own screens and widgets:

- **`auth/`**: Authentication and onboarding
- **`home/`**: Main dashboard, crop library, search
- **`ai_scan/`**: Camera capture and AI analysis
- **`profile/`**: User profile management
- **`main/`**: Main navigation container

### Core Infrastructure
- **`core/config/`**: Environment and app configuration
- **`core/theme/`**: Material 3 theming system
- **`core/utils/`**: Utility functions and diagnostics
- **`core/providers/`**: Global state providers

### Data Flow
1. **UI Layer**: Screens and widgets consume providers
2. **Provider Layer**: Manages state and calls services
3. **Service Layer**: Handles business logic and external APIs
4. **Data Layer**: Supabase database and local storage

### Key Design Patterns
- **Dependency Injection**: Services injected via providers
- **Repository Pattern**: Data access abstraction
- **Observer Pattern**: Provider state notifications
- **Factory Pattern**: Service initialization
- **Singleton Pattern**: Global service instances

### Error Handling
- Try-catch blocks in services
- Debug prints for development
- User-friendly error messages
- Graceful degradation for offline scenarios