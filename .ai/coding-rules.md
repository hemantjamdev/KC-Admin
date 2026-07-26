# Coding Rules

## Principles

- Production-quality code only.
- Write null-safe code.
- Small, focused classes with single responsibilities.
- Clear, self-describing variable and class names.
- No duplicated logic across components.
- No commented-out code in committed files.
- No dead code or unused imports.
- No temporary `print()` or `debugPrint()` statements.
- Avoid magic strings and magic numbers—extract to constants.
- Avoid unnecessary abstraction; prefer simple composition over inheritance.
- Prefer immutable values and declare variables `final`.
- Use `const` constructors wherever possible.
- Use early returns to keep method bodies flat and readable.
- Handle failures explicitly using `AppResult` or `AppFailure`. Do not silently catch and swallow exceptions.
- Avoid deeply nested widget trees.
- Add comments only when technical rationale or non-obvious business logic is required. Do not repeat code in comments.
- Do not leave generic `TODO` comments without explanation and owner context.
