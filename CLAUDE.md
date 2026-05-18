# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Flutter Commands
- `flutter run` - Run the app in development mode
- `flutter build web` - Build for web deployment
- `flutter build apk` - Build APK for Android
- `flutter clean` - Clean build artifacts
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Update dependencies

### Testing Commands
- `flutter test` - Run unit tests
- `flutter test integration_test/` - Run integration tests
- `flutter test test/widget_tests/` - Run widget tests
- `flutter test test/performance/` - Run performance tests

### Code Quality
- `flutter analyze` - Run static analysis
- `dart format .` - Format code
- `flutter test --coverage` - Generate test coverage report

### Build Commands
- `flutter build web --release` - Production web build
- `flutter build apk --release` - Production Android build

## Architecture Overview

This is a Flutter job portal application using a layered architecture:

### Core Architecture
- **State Management**: Hybrid approach using both Riverpod and Provider
  - Riverpod: Primary state management for most features
  - Provider: Specifically for notifications (`NotificationProvider`)
- **Routing**: Traditional Flutter routing with `MaterialApp` routes and `onGenerateRoute` for dynamic routing
- **Backend**: Firebase services (Auth, Firestore, Storage) + REST API backend
- **Environment**: Uses `flutter_dotenv` for environment variables (`.env` file)

### Directory Structure
```
lib/
├── config/           # Configuration files and themes
├── core/            # Core utilities, constants, and routes
├── data/            # Data layer (models, providers, repositories)
├── extension/       # Dart extensions
├── services/        # Service layer for API calls
├── ui/             # UI layer (pages and widgets)
├── viewmodel/      # ViewModels for business logic
├── api_service.dart # Main API service
├── main.dart       # App entry point
└── firebase_options.dart # Firebase configuration
```

### Key Components
- **Authentication**: Firebase Auth with custom user roles (admin/company/individual)
- **Job Management**: Job posting, application, and company management
- **Resume System**: Resume creation, editing with Quill editor
- **Admin Panel**: Comprehensive admin features for managing users, content, and system
- **Payment System**: Integration for job posting and premium features
- **Content Management**: Board, notice, inquiry, and resource systems

### Testing Structure
- Unit tests for services (auth, board, resume, etc.)
- Integration tests for full workflows
- Widget tests for UI components
- Performance tests for optimization
- Mock objects generated using `mockito` and `build_runner`

### State Management Patterns
- Uses `ConsumerWidget` from Riverpod for reactive UI
- `StateProvider` and custom providers for various app states
- Traditional `ChangeNotifier` pattern for notifications via Provider

### Key Dependencies
- **UI**: Material Design 3 with custom theming
- **Networking**: `dio` for HTTP requests, Firebase SDK
- **Storage**: `flutter_secure_storage`, `shared_preferences`, `hive`
- **Rich Text**: `flutter_quill` for resume/content editing
- **File Handling**: `file_picker`, `image_picker`
- **Development**: Comprehensive testing stack with `mockito`, `faker`, `golden_toolkit`