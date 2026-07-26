# AI Development Instructions - Kapada Creation Admin App

This repository contains the **Kapada Creation Admin App** (`kc_admin` / `com.kc.kcadmin.app`).

Before making any change in this repository, read:

1. `.ai/project-context.md`
2. `.ai/product-rules.md`
3. `.ai/ai-behavior-rules.md`
4. `.ai/architecture-rules.md`
5. `.ai/folder-structure-rules.md`
6. `.ai/coding-rules.md`
7. The rule file related to the current task

Do not make assumptions about missing requirements.

Do not introduce packages, architecture changes, Firebase listeners, new patterns, or visual styles without checking the project rules.

All generated code must pass:

- `dart format .`
- `flutter analyze`
- `flutter test`

Never modify generated files manually.

Never expose secrets, tokens, Firebase keys, customer data, or private information.

If a requested implementation conflicts with these rules, stop and report the conflict before changing code.

## Application Identity

- Application: Kapada Creation Admin App
- Flutter Project: `kc_admin`
- Application ID: `com.kc.kcadmin.app`
- Identity & Focus: Fast, operational, clear, simple, reliable, and efficient management tool for boutique owners and branch operators.
