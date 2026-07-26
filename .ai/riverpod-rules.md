# Riverpod Rules

- **Exclusive Choice**: Riverpod is the sole state-management system. Do not use Bloc, Cubit, GetX, Provider package, MobX, or Redux.
- **Provider Types**:
  - `Provider`: For immutable dependencies, repositories, and services.
  - `FutureProvider`: For read-only asynchronous data fetching.
  - `Notifier`: For synchronous state management.
  - `AsyncNotifier`: For asynchronous workflows and state transitions.
  - Family providers: For parameterized identifiers or filters.
- **Scoping**: Keep providers close to their respective module files. Do not dump all providers into one global file.
- **Side Effects**: Do not trigger state mutations or side-effects directly inside widget `build()` methods.
- **Immutability**: Never expose mutable collections from providers.
- **No BuildContext**: Controllers must not accept or store `BuildContext`. Controllers return domain results or update state.
- **Testability**: All providers must be overrideable during testing (`ProviderScope(overrides: [...])`).
- **Refresh**: Use `ref.invalidate()` or explicit controller refresh methods for manual data reloads.
- **No StreamProvider**: Do not use `StreamProvider` for normal application data or Firestore snapshot listeners.
- **Codegen**: Use `riverpod_annotation` (`@riverpod`) where code generation is appropriate.
- **Generated Files**: Never edit `*.g.dart` files manually.
