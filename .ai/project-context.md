# Fixed Project Context - KC-Admin

## Technical Context

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Riverpod (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`)
- **Model Generation**: Freezed (`freezed`, `freezed_annotation`) + JSON Serializable (`json_annotation`, `json_serializable`)
- **Networking**: Dio (`dio`)
- **Navigation**: GoRouter (`go_router`)
- **Backend**: Firebase (to be configured in a separate task)
- **Icons**: Phosphor Flutter (`phosphor_flutter`)
- **SVG**: Flutter SVG (`flutter_svg`)
- **Animations**: Flutter built-in animations + Flutter Animate (`flutter_animate`)
- **Architecture**: Feature-first modular architecture
- **Data Access**: Repository pattern
- **Normal Data Loading**: One-time fetch + manual pull-to-refresh
- **Pagination**: Cursor-based

## Repository & Project Boundaries

- `KC-App` and `KC-Admin` are completely separate Flutter projects and independent Git repositories.
- They follow the same engineering rules but do not share source files directly.
- Similar models and rules must remain compatible across both applications.
- Do not initialize a Git repository in the parent `KC` folder.
- Firebase setup will be added in a separate dedicated task.
- Do not add production features unless explicitly requested.
