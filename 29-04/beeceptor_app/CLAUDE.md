# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter mobile app that displays posts fetched from a Beeceptor mock API (`https://json-placeholder.mock.beeceptor.com/posts`). Educational project for the 4ESWADS/5ADS course.

## Common Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run app (debug mode)
flutter test             # Run tests
flutter analyze          # Run static analysis (flutter_lints)
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app
```

## Architecture

Layered architecture with Provider for state management:

```
lib/
├── main.dart              # Entry point, GoRouter routes, MultiProvider DI setup
├── models/                # Data classes with fromJson() factories
├── services/              # API layer (Dio HTTP client)
├── providers/             # ChangeNotifier state management
├── ui/
│   ├── screens/           # Full page widgets
│   └── widgets/           # Reusable UI components
└── utils/                 # Utilities (currently empty)
```

**Data flow:** `Service (Dio HTTP) → Provider (ChangeNotifier) → UI (Consumer widget)`

**Routing:** GoRouter with named routes defined in `main.dart`:
- `/` → HomePage
- `/posts` → PostsPage

**Dependency Injection:** MultiProvider in `main.dart` injects Dio instance into PostsService, which is injected into PostsProvider.

## Key Dependencies

- **dio** - HTTP client for API requests
- **go_router** - Declarative navigation/routing
- **provider** - State management via ChangeNotifier pattern

## State Management Pattern

Providers extend `ChangeNotifier` and manage three states: loading, error, and success. Screens use `Consumer<T>` to rebuild on state changes. See `PostsProvider` for the established pattern.