# Freezed & Model Rules

- Use **Freezed** for immutable domain models, application state classes, failures, and results.
- Use **JSON Serializable** for serialized data models.
- Add explicit `@JsonKey(name: '...')` annotations to every serialized field.
- Every backend model must provide `fromJson` factory and `toJson` method.
- Use nullable fields where backend values are optional.
- Use default values for safe empty values (e.g. `@Default([]) List<String> items`). Do not use defaults that conceal missing required backend fields.
- Document and entity IDs must remain explicit fields.
- Do not use raw Firebase `DocumentSnapshot` objects directly as application models—map them in data sources/mappers.
- Use custom converters for DateTime timestamps and Enums.
- Do not serialize UI-only transient states.
- Never edit `*.freezed.dart` or `*.g.dart` manually. Run `dart run build_runner build --delete-conflicting-outputs`.

## Distinct Identifier Names

Keep entity identifiers distinct:
- `firebaseUid`
- `customerId`
- `boutiqueId`
- `branchId`
- `designId`
- `stitchingId`
- `sectionId`
- `notificationId`
