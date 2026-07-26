# Folder Structure Rules

## Required Root Structure

```text
lib/
├── main.dart
└── src/
    ├── app/
    │   ├── router/
    │   └── theme/
    ├── bootstrap/
    ├── config/
    │   └── environment/
    ├── core/
    │   ├── constants/
    │   ├── errors/
    │   ├── extensions/
    │   ├── logging/
    │   ├── network/
    │   ├── pagination/
    │   ├── result/
    │   ├── services/
    │   └── utils/
    ├── modules/
    ├── shared/
    │   ├── animations/
    │   ├── models/
    │   ├── providers/
    │   └── widgets/
    └── src.dart
```

## Module Structure

Each feature module under `lib/src/modules/` must use the following layout:

```text
module_name/
├── data/
│   ├── datasources/
│   ├── mappers/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── application/
│   ├── controllers/
│   ├── providers/
│   └── states/
├── presentation/
│   ├── pages/
│   ├── sections/
│   └── widgets/
└── module_name.dart
```

## Rules

- Every major folder and module gets a barrel export file.
- Do not create empty directories without active use (except `.gitkeep` for required structure).
- Do not place feature-specific widgets inside `shared/`.
- Do not place domain models inside `core/`.
- File names must strictly use `snake_case`.
- Large presentation pages must be split into composed `sections/` and `widgets/`.
