# Error Handling Rules

- All application errors must be mapped into strongly typed `AppFailure` models inside repositories.
- Controllers process `AppFailure` and update state accordingly.
- UI components display user-friendly error views (`AppErrorView`) with retry actions.
- **Never** display raw exception messages, stack traces, Dio errors, or Firebase exception strings directly to end-users.
- Preserve existing valid cached data if a background refresh operation fails.
- Show an initial full-screen error view with retry option only when no previous data exists.
- Show inline retry triggers for failed paginated load-more actions.
- Preserve user-entered form values if a form submission operation fails.
- All unexpected errors must be logged through `AppLogger`.
- Avoid empty `catch` blocks. Never catch an exception without logging, handling, or rethrowing it.
- Network connection failures must show an explicit network error state rather than presenting empty data.
