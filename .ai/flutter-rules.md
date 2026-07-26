# Flutter Development Rules

- Use Material 3 foundation by default.
- Business state must **NEVER** live inside a `StatefulWidget`.
- `StatefulWidget` is reserved strictly for local UI concerns (e.g. animation controllers, scroll controllers, focus nodes).
- Extend `ConsumerWidget` or `ConsumerStatefulWidget` when accessing Riverpod providers.
- Pass data into child widgets via typed parameters rather than reading providers deep inside small reusable widgets.
- Use explicit `Key` parameters for dynamic and reorderable lists.
- Respect `SafeArea` boundaries and handle keyboard insets gracefully.
- Always dispose local controllers (`AnimationController`, `TextEditingController`, `ScrollController`) in `dispose()`.
- Do not use `BuildContext` across `async` gaps without checking `if (!context.mounted) return;`.
- Do not hard-code device screen sizes. Use `LayoutBuilder`, `MediaQuery`, constraints, or responsive utility rules.
- Avoid fixed heights for dynamic or localized text content.
- Every asynchronous screen must explicitly handle 4 states:
  1. Loading state (`AppLoadingView`)
  2. Error state (`AppErrorView`)
  3. Empty state (`AppEmptyView`)
  4. Success state (Data content)
- Pull-to-refresh (`AppRefreshIndicator`) must remain available on data-driven screens.
