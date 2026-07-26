# Code Review Checklist

Use this checklist during code review before completing any task:

## Scope
- [ ] Only requested work is implemented.
- [ ] No unrelated refactoring or unasked features added.

## Architecture
- [ ] Code is placed in the correct module and layer.
- [ ] No direct Firebase or Dio calls inside UI widgets.
- [ ] Abstract repository contracts are used.
- [ ] No continuous database snapshot listeners introduced.

## State Management
- [ ] Riverpod used exclusively.
- [ ] No business state in `StatefulWidget`.
- [ ] Duplicate request prevention is active.
- [ ] Pull-to-refresh works properly.
- [ ] Pagination is safe and cursor-based.

## UI & UX
- [ ] Loading, error, empty, and success states exist.
- [ ] Responsive layout constraints respected.
- [ ] No staff role / enterprise permissions added.

## Models & Quality
- [ ] Freezed used for domain state; JsonKey present.
- [ ] No manual edits to `.g.dart` or `.freezed.dart`.
- [ ] `dart format .` passes.
- [ ] `flutter analyze` passes with 0 issues.
- [ ] `flutter test` passes 100%.
- [ ] No committed secrets or private credentials.
