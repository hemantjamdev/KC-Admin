# Git & Workflow Rules

- `KC-App` and `KC-Admin` are completely independent Git repositories.
- **Strict Prohibition**: Never run Git commands in the parent `KC` directory.
- Primary working branch is `dev`, default integration branch is `main`.
- Use Conventional Commit messages:
  - `feat: ...`
  - `fix: ...`
  - `refactor: ...`
  - `chore: ...`
  - `docs: ...`
  - `test: ...`
  - `style: ...`
  - `perf: ...`
- Keep commits atomic and focused. Do not mix unrelated tasks in a single commit.
- Never commit secrets, credentials, or local environment overrides.
- Do not use force push (`--force`) without explicit user approval.
- Do not reset or delete remote branches without explicit user approval.
- Do not push automatically unless the task explicitly requests pushing.
- Always run `dart format .`, `flutter analyze`, and `flutter test` before committing.
