# Architecture Rules

## Application Flow

```text
Presentation (Widget / Page)
    ↓
Riverpod Controller (Notifier / AsyncNotifier)
    ↓
Repository Contract (Interface in domain/)
    ↓
Repository Implementation (Class in data/repositories/)
    ↓
Data Source (Class in data/datasources/)
    ↓
Firebase / Dio / Storage
```

## Architectural Constraints

- **Presentation Layer**: Contains pages, sections, and widgets. Widgets must never call Firebase or Dio directly, nor instantiate repositories directly. They may only interact with Riverpod providers.
- **Application Layer**: Contains state objects, controllers (`Notifier`, `AsyncNotifier`), and providers. Coordinates UI actions and reads repositories.
- **Domain Layer**: Contains entities, repository contracts, and optional use-cases for complex workflows.
- **Data Layer**: Contains data sources (SDK specific calls), models (Freezed / JSON Serializable), mappers, and repository implementations.
- **Use Cases**: Use-case classes are reserved only for complex multi-repository business workflows. Do not create one use-case class per CRUD method.
- **Repositories**: Do not create one massive generic repository with unrelated CRUD operations. Each module defines its own focused repository contract.
- Keep core independent from features. Keep feature-specific logic inside module folders.
- Avoid circular exports and dependencies. Never import presentation into application, domain, or data layers.
