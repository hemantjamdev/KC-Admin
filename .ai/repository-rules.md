# Repository Pattern Rules

- Every data-driven module defines an abstract repository contract (interface) in `domain/repositories/`.
- Repository implementations belong in `data/repositories/`.
- SDK-specific code (Dio, Firestore, Local Storage) belongs strictly inside `data/datasources/`.
- Controllers and application logic depend solely on abstract repository contracts, never on concrete implementations.
- Repositories catch technical exceptions and map them into strongly-typed `AppFailure` objects.
- Do not return raw Firebase exceptions or Dio exceptions to controllers or UI.
- Use explicit one-time fetch methods (`Future<AppResult<T>>`).
- Pagination repository methods must return cursor-independent application models (`PaginatedResult<T>`).
- Repository method names must express business intent (e.g. `fetchBranchDesigns()`, `updateStitchingStatus()`).
- Avoid generic method names like `doRequest()` or `handleData()`.
- Avoid creating one massive single repository for the entire application.
- Multi-step operations or transactions belong inside repository implementations or domain use-cases.
- Repositories must be fully mockable for unit testing.
