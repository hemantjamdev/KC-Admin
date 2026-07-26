# Data Loading Rules

## Core Data Fetching Strategy

> [!CRITICAL]
> The application does **NOT** use continuous database listeners for normal application data.
> Do **NOT** use Firestore snapshots, continuous streams, or `StreamProvider` for normal data.

```text
Open screen
    ↓
Fetch latest data (one-time Future)
    ↓
Display cached state in Riverpod
    ↓
User pulls to refresh (AppRefreshIndicator)
    ↓
Fetch latest data again
```

## Specific Data Loading Guidelines

- Fetch data once on initial screen load.
- Hold loaded data in Riverpod state (`AsyncNotifier` or `Notifier`).
- Data is re-fetched **ONLY** when:
  - User explicitly pulls to refresh (`AppRefreshIndicator`).
  - User taps a retry button after a failure.
  - User switches the active branch.
  - User applies new filter criteria or search query.
  - A mutation succeeds and local state requires update.
  - User explicitly revisits the screen and refresh policy demands a update.
- Do **NOT** refetch data on every widget rebuild or when switching between minor child tabs.
- Prevent duplicate requests while a fetch operation is already in progress.
- Preserve previous valid data during background refresh operations (avoid flashing screen loaders).
- Show full-screen loader (`AppLoadingView`) only on initial load when no data exists.
- Pagination must be cursor-based (`nextCursor`, `hasMore`). Default page size is 20.
- Deduplicate paginated items using stable entity IDs.
- Results from old queries must never mix with new query results.
- Changing branch must immediately reset branch-scoped state.
