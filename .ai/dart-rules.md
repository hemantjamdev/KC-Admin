# Dart Language Rules

- Follow Effective Dart guidelines (`style`, `documentation`, `usage`, `design`).
- Always specify explicit return types on methods and functions.
- Mark local variables and fields `final` by default.
- Use `const` constructors for immutable objects.
- Avoid using `dynamic`; prefer strong typing or generic parameters.
- Avoid force unwrapping (`!`) unless logically guaranteed non-null and documented.
- Use switch expressions and pattern matching where it improves readability.
- Use sealed classes (e.g. `AppFailure`, `AppResult`) for controlled state variations.
- Prefer named parameters for methods with two or more arguments.
- Required named parameters must be marked with `required`.
- Use nullable fields only when absence is a valid state.
- Avoid unnecessary `late` variables.
- Avoid global mutable variables.
- Avoid utility classes containing unrelated methods—group by responsibility.
- Use extension methods only for clear, reusable domain or framework extensions.
- Keep file lengths manageable with one primary responsibility per file.
