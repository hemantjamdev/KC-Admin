# KC Admin

Kapada Creation admin application.

## Current Setup

- Flutter
- Android
- iOS
- Basic Flutter counter application

## Application ID

`com.kc.kcadmin.app`

## Architecture

This application uses:

- Feature-first modular architecture
- Riverpod for state management and dependency injection
- Freezed for immutable models and states
- Repository pattern for data access
- GoRouter for navigation
- Dio for HTTP integrations
- Manual refresh and cursor-based pagination

The application does not use continuous database listeners for normal data.
Data is fetched on screen load, pagination, or explicit pull-to-refresh.
