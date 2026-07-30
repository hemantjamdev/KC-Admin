# Architecture Rules — KC-Admin

**These are hard requirements, not recommendations.**
**Generated code failing these rules must be rejected and corrected before merging.**

---

## 1. State Management Policy

Riverpod is the **mandatory** state-management and dependency-injection framework.

Required packages:
```
flutter_riverpod
riverpod_annotation
riverpod_generator
build_runner
```

Feature state must use one of:
```
Provider / FutureProvider / StreamProvider
Notifier / AsyncNotifier
AutoDisposeNotifier / AutoDisposeAsyncNotifier
NotifierProvider / AsyncNotifierProvider
```

Use `@riverpod` generator annotations throughout.

**Forbidden for feature state:**
- `ChangeNotifier` / `ChangeNotifierProvider`
- `ValueNotifier` for business state
- `InheritedWidget` / `InheritedNotifier` for feature state
- GetX, Bloc, Cubit, Provider package
- Manual singleton feature controllers
- Manual event-bus state

All existing `ChangeNotifier` feature controllers must be migrated.

---

## 2. Riverpod Is Mandatory in Every Module

Every business module must expose state and dependencies through providers:

| Module | Required Providers |
|---|---|
| Auth | session, login mutation, logout |
| Boutiques | list, selected (keepAlive), repository |
| Branches | list, selected (keepAlive), repository |
| Categories | list by boutique, details, mutation (admin) |
| Sections | list, details, mutation (admin) |
| Designs | list, details, availability, mutation (admin) |
| Customers | list (admin), current (app), details, mutation |
| Stitching Orders | list, details, status mutation |
| Notifications | list, unread count, mutation |
| Dashboard | aggregated stats |

A module is **incomplete** if the UI creates its own feature controller.

---

## 2.1 List Pagination Policy

All list queries for high-volume collections (Products/Designs, Stitching Orders, Customers, Activity Logs, Notifications) **must** implement chunked pagination (`pageSize: 20` default with `startAfterDocument` cursor). Unpaginated fetch of full collections is strictly forbidden.

---

## 3. Widget Policy

### `ConsumerWidget` — default for:
- Pages, list screens, detail screens, dashboard, read-only forms
- Any widget that watches providers

### `ConsumerStatefulWidget` — only when owning disposable UI resources:
- `TextEditingController`, `FocusNode`, `AnimationController`
- `ScrollController`, `PageController`, `TabController`
- Business data must still come from Riverpod

### `StatelessWidget` — pure presentational widgets receiving all data through constructor

### `StatefulWidget` — isolated local visual behavior only. **Forbidden for pages reading feature data.**

---

## 4. `initState()` Policy

`initState()` **must not** perform business data loading.

**Forbidden inside `initState()`:**
```dart
repository.get...()
controller.load...()
FirebaseFirestore.instance...
FirebaseAuth.instance...
addListener(_onControllerUpdate)
ref.read(...).load()
Future.microtask(() => loadData())
WidgetsBinding.instance.addPostFrameCallback((_) => fetchData())
```

Also forbidden hidden inside:
- `didChangeDependencies` for business loading
- `Future.delayed` for data loading
- Manual controller constructors

**Allowed in `initState()`:**
- Creating `TextEditingController`, `FocusNode`, `AnimationController`
- Registering animation-only listeners
- Reading static route arguments already passed to the widget

Riverpod provider initialization triggers loading through `build()`, `FutureProvider`, `StreamProvider`, or `AsyncNotifier.build()`.

---

## 5. `setState()` Policy

`setState()` is allowed **only for ephemeral local UI state**.

**Allowed:**
- Password visibility toggle
- Accordion expand/collapse
- Image carousel page index
- Animation-only flags

**Forbidden — must use Riverpod:**
- Loading, error, fetched list data
- Firestore documents
- Authentication state
- Current boutique/branch/customer
- Search results, filters, pagination
- Form submission state
- CRUD status
- Any repository response

---

## 6. Controller Policy

**Forbidden:**
```dart
class DesignController extends ChangeNotifier { }
final controller = DesignController(...);  // in widget
late DesignController _controller;         // in widget
```

**Required:**
```dart
@riverpod
class DesignListController extends _$DesignListController {
  @override
  Future<List<Design>> build({required String boutiqueId}) async { ... }
}

// In widget:
final state = ref.watch(designListControllerProvider(boutiqueId: id));
```

---

## 7. Clean Architecture Dependency Rules

```
Presentation → Application → Domain ← Data
```

**Domain must NOT import:** Flutter, Riverpod, Firebase, Firestore, Material, Cupertino, Presentation, Data implementations.

**Application may import:** Riverpod, Domain entities, Domain repository interfaces, Application state.

**Application must NOT import:** Flutter widgets, Material, Cupertino, concrete Firestore repositories, Presentation pages.

**Presentation may import:** Flutter, Riverpod providers, Application state, Domain entities, shared widgets.

**Presentation must NOT import:** Firestore data sources, concrete repositories, mock data, Firebase SDK instances, Data-layer models when domain entities exist.

**Data implements Domain interfaces. Concrete dependencies injected through Riverpod.**

---

## 8. Repository Policy

**Domain interface:**
```dart
abstract interface class DesignRepository {
  Future<List<Design>> getDesigns({required String boutiqueId});
  Stream<List<Design>> watchDesigns({required String boutiqueId});
}
```

**Data implementation:**
```dart
final class FirestoreDesignRepository implements DesignRepository { ... }
```

**Riverpod provider:**
```dart
@riverpod
DesignRepository designRepository(Ref ref) {
  return FirestoreDesignRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}
```

**Forbidden:** Widgets constructing repositories. Widgets calling Firebase APIs directly.

---

## 9. Data Source Policy

External SDK calls belong in data sources only:
```
data/
├── datasources/     ← Firebase, REST, local DB calls here
├── models/
├── mappers/
└── repositories/    ← implements domain interfaces
```

Do not expose Firebase snapshots or SDK types to Presentation or Application layers.

---

## 10. Immutable State Policy

Feature state must be immutable. Use Freezed:
```dart
@freezed
class DesignFilterState with _$DesignFilterState {
  const factory DesignFilterState({
    @Default('') String query,
    String? categoryId,
    @Default(false) bool activeOnly,
  }) = _DesignFilterState;
}
```

State objects must not expose mutable public lists or maps. Do not mutate collections in place.

---

## 11. Async State Policy

Use `AsyncValue<T>` for async feature state:
```dart
state.when(loading: ..., error: ..., data: ...);
```

**Forbidden page-local variables:**
```dart
bool _isLoading;
String? _error;
List<Item> _items;
```

Do not silently convert repository failures into empty lists. Errors must be visible and retryable.

---

## 12. Form State Policy

**Local field controllers** (may stay in `ConsumerStatefulWidget`):**
- `TextEditingController`, `FocusNode`, `FormKey`

**Business form state (must use Riverpod):**
- Submitting, submission error, validation, selected items, save success

Pattern:
```
<feature>_form_state.dart     ← Freezed state
<feature>_form_controller.dart ← @riverpod Notifier
```

---

## 13. Selected Boutique and Branch Policy

Selected boutique and branch are **global session context** exposed through `keepAlive` providers.

**Forbidden:** Copying boutique/branch into page-local state.

**Required:** All pages use `ref.watch(selectedBoutiqueProvider)`.

Changing selection must invalidate dependent providers:
```dart
ref.invalidate(designListProvider);
ref.invalidate(categoryListProvider);
```

---

## 14. Provider Lifetime Policy

- `autoDispose` by default for screen-scoped data
- `keepAlive` only for: auth session, selected boutique, selected branch, long-lived repositories, app configuration
- Use family parameters for entity-scoped state: `designDetailsProvider(designId)`

---

## 15. Provider Side-Effect Policy

Use `ref.listen()` for UI side effects (snackbar, navigation, dialog).

**Forbidden:**
- Navigating inside repository code
- Passing `BuildContext` into notifiers, repositories, or use cases
- Storing `BuildContext`

---

## 16. No Service Locator Policy

**Forbidden:** GetIt, global mutable singletons, static repository instances, Firebase instances directly in feature widgets, manual dependency containers.

Riverpod is the only DI mechanism.

---

## 17. Mock Data Policy

Production feature code must not import mock data. Repositories must not silently fall back to mock data.

Errors must return failures or throw typed exceptions. Test fixtures belong in `test/` only.

---

## 18. Provider Naming Policy

```
<feature>RepositoryProvider       ← dependency
<feature>ListProvider              ← read state
<feature>DetailsProvider           ← entity state
<feature>FormControllerProvider    ← mutation
<feature>FilterProvider            ← filter state
selectedBoutiqueProvider           ← session
selectedBranchProvider             ← session
authSessionProvider                ← auth
```

---

## 19. Authentication Policy

Auth state must come from a single Riverpod session provider. Do not check Firebase Auth independently in multiple pages. Router redirects must read the central auth/session state.

---

## 20. Error Handling Policy

Distinguish at minimum:
- Network error
- Permission denied
- Not found
- Unauthenticated / Unauthorized
- Validation failure
- Unknown error

Log the technical error. Expose safe UI messages. Never catch every exception and return an empty list.

---

## 21. Pagination Policy

Pagination uses a dedicated Riverpod notifier. State includes: items, loading first page, loading next page, cursor, has more, error, refreshing.

Scroll listener may only call: `ref.read(provider.notifier).loadNextPage()`.

---

## 22. Testing Policy

Every migrated module must have tests for:
- Notifier initial state
- Successful loading
- Empty state
- Failure state
- Retry
- Mutation success / failure
- Provider invalidation
- Repository dependency override via fake

---

## 23. Architecture Rejection Rules — TASK INCOMPLETE CONDITIONS

Future generated code is **rejected** if any feature:

```
☐ Creates a ChangeNotifier
☐ Loads business data inside initState
☐ Manually listens to a controller (addListener)
☐ Calls setState for fetched data
☐ Imports mock data in production code
☐ Imports Data implementation from Presentation
☐ Calls Firebase directly from a widget or page
☐ Constructs a repository inside a widget
☐ Stores BuildContext in application or domain code
☐ Uses mutable feature state objects
☐ Hides repository errors (empty list on failure)
☐ Adds a second state-management framework
☐ Has no Riverpod providers for a business module
☐ Reads business state without Riverpod
☐ Leaves old and new controllers coexisting for the same feature
```

---

## 24. Required AI Behavior

Before generating feature code, confirm internally:
1. Domain entity
2. Repository interface
3. Data implementation
4. Riverpod dependency provider
5. Riverpod state provider / notifier
6. UI consumer
7. Tests

Do not generate page code before confirming the state flow.
Do not create placeholder folders with no real separation.
Do not claim Clean Architecture merely because folders exist.
