# AI Behavior Rules

## General Execution Rules

- Read existing code and relevant `.ai/` rules before making edits.
- Do not throw large implementations into one task; work incrementally.
- Implement only the explicitly requested scope.
- Do not create future feature modules early.
- Do not make architectural changes silently.
- Do not replace working code without a valid, documented reason.
- Do not generate fake backend data unless explicitly requested.
- Do not add placeholder business logic that appears production-ready.
- Do not invent requirements or add features because they are common in other apps.
- Report conflicts and assumptions immediately before proceeding.
- Keep responses and summaries concise.
- Prefer modifying existing files over creating duplicate alternatives.
- Preserve naming and directory conventions.
- Never edit generated `.g.dart` or `.freezed.dart` files manually.
- Never run destructive Git commands without explicit user approval.
- Never push automatically unless the task explicitly requests it.
- Never configure Firebase using guessed identifiers.
- Never add continuous Firebase snapshot listeners.

## Completion Summary Requirement

At the end of every turn, AI agents must show:
- Files created
- Files modified
- Packages added
- Commands executed
- Tests performed
- Known limitations
