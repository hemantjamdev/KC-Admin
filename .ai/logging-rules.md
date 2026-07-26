# Logging Rules

- All logging must be executed via `AppLogger` (`appLoggerProvider`).
- Do **NOT** use `print()` or `debugPrint()` in application code.
- Logs are enabled only in `development` and `staging` environments via `EnvironmentConfig`.
- Log errors at the layer where technical context is first known (e.g. data source / repository).
- **Strict Prohibition**: Never log sensitive information, including:
  - Auth tokens or refresh tokens
  - Passwords or credentials
  - Personal customer data (email, phone, address)
  - Full raw Firebase/Firestore documents
  - Private stitching notes
- Separate technical developer logs from user-facing error strings.
