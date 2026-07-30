# AI Development Instructions — Kapada Creation Admin App

This repository contains the **Kapada Creation Admin App** (`kc_admin` / `com.kc.kcadmin.app`).

Before making **any** change in this repository, read these files in order:

1. `.ai/project-context.md`
2. `.ai/product-rules.md`
3. **`.ai/architecture-rules.md` ← MANDATORY — read before every code change**
4. `.ai/ai-behavior-rules.md`
5. `.ai/folder-structure-rules.md`
6. `.ai/coding-rules.md`
7. The rule file specific to the current task type (e.g. `.ai/firebase-rules.md`, `.ai/testing-rules.md`)

---

## Architecture Mandate

This app uses **Riverpod as the mandatory state-management and DI framework**.

The following are **hard rejection conditions** — code with any of these is incomplete and must not be merged:

- `ChangeNotifier` or `ChangeNotifierProvider` used for feature state
- Business data loaded inside `initState()`
- `setState()` called for fetched/persistent feature data
- `addListener()` / `removeListener()` on feature controllers
- Presentation importing concrete Data repository implementations
- Widgets constructing repositories or calling Firebase directly
- Mock data imported in production feature code
- `BuildContext` stored in application/domain code
- A second state-management framework introduced

All feature state must use Riverpod (`FutureProvider`, `StreamProvider`, `Notifier`, `AsyncNotifier`).
All pages reading feature data must be `ConsumerWidget` or `ConsumerStatefulWidget`.

---

## List Pagination Mandate

All feature listing queries (Designs/Products, Stitching Orders, Customers, Notifications, etc.) **MUST** implement generic chunked pagination (default page limit of 20 items with cursor-based pagination). Loading unpaginated full collections for scalable features is strictly forbidden.

---

For the full 24-rule mandate with examples, see `.ai/architecture-rules.md`.

---

## Code Quality Gates

All generated or modified code must pass:

```bash
dart format .
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Never modify generated `.g.dart` or `.freezed.dart` files manually.

Never expose secrets, tokens, Firebase keys, customer data, or private information.

If a requested implementation conflicts with these rules, stop and report the conflict before changing code.

---

## Application Identity

- Application: Kapada Creation Admin App
- Flutter Project: `kc_admin`
- Application ID: `com.kc.kcadmin.app`
- Identity & Focus: Fast, operational, clear, simple, reliable, and efficient management tool for boutique owners and branch operators.

---

## Feature Structure

```
features/<feature>/
├── data/
│   ├── datasources/
│   ├── models/
│   ├── mappers/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/   ← abstract interfaces only
│   └── usecases/
├── application/
│   ├── controllers/    ← @riverpod Notifier/AsyncNotifier
│   ├── providers/
│   └── state/          ← @freezed state classes
└── presentation/
    ├── pages/
    └── widgets/
```
