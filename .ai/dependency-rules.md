# Dependency Rules

- Add new packages only when they solve an explicit requirement that Flutter SDK cannot provide natively.
- Prefer actively maintained, popular stable packages.
- Avoid redundant or overlapping dependencies.
- Do not add packages preemptively for future hypothetical requirements.
- Do not perform major package version upgrades during unrelated feature work.
- Any newly added dependency must be explicitly documented in completion summaries.
- Firebase packages require a dedicated Firebase setup task.
- Do **NOT** add alternative state-management packages (Bloc, MobX, GetX).
- Do **NOT** add alternative routers or icon libraries.
- Remove unused dependencies from `pubspec.yaml`.
- Package version constraints must remain compatible with current Flutter SDK.
