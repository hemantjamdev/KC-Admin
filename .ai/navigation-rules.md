# Navigation Rules

- Use **GoRouter** (`go_router`) exclusively for application routing and deep linking.
- Route paths must be centralized in `lib/src/app/router/route_paths.dart`.
- Never hard-code string route paths inside page widgets. Use constants or named routes.
- Route parameters must be strongly typed and validated upon entry.
- Display a dedicated Not-Found screen (`AppEmptyView` / error) if a target record ID does not exist.
- Centralize authentication and branch-guard redirects in GoRouter configuration.
- Do not put complex business logic inside route builder methods.
- Page transitions must follow application animation rules (`FadeSlideTransition`).
- Navigation services must be exposed via Riverpod (`appRouterProvider`) and never as global mutable singletons.
- Do not create production routes before their corresponding feature modules exist.
