# Feature Development Workflow

Follow this exact 18-step sequential workflow when developing any feature:

1. Read product context (`.ai/product-rules.md`).
2. Read related technical rules (`.ai/architecture-rules.md`, `.ai/riverpod-rules.md`, etc.).
3. Inspect existing codebase implementation.
4. Confirm exact feature scope from task prompt.
5. Identify required target module and layer structure.
6. Create or update abstract domain contract (`domain/repositories/`).
7. Create or update data source (`data/datasources/`).
8. Create or update repository implementation (`data/repositories/`).
9. Create Riverpod controller and state (`application/controllers/`).
10. Create presentation pages and widgets (`presentation/`).
11. Implement loading, empty, error, and retry UI states.
12. Implement pull-to-refresh (`AppRefreshIndicator`) for refreshable screens.
13. Add unit and widget tests (`test/`).
14. Execute code generation (`dart run build_runner build --delete-conflicting-outputs`).
15. Run formatting (`dart format .`).
16. Run static analysis (`flutter analyze`).
17. Run automated test suite (`flutter test`).
18. Provide concise completion summary.

## Workflow Rules

- Implement one feature at a time.
- Do not create unrelated future screens early.
- Do not alter global architecture without approval.
- Do not make backend schema decisions based on unverified guesses.
