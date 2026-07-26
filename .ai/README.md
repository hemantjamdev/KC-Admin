# KC-Admin AI & Project Rules Index

## Purpose of Rules Directory

This directory contains permanent engineering, product, architectural, and behavioral guidelines for human developers and AI coding agents working on **KC-Admin** (`kc_admin`).

## Task-to-Rule Map

When working on specific tasks, AI agents must read the relevant rule file before proceeding:

- **Feature Work** → `feature-development-workflow.md` + `architecture-rules.md`
- **UI / UX Work** → `design-system-rules.md` + `ui-ux-rules.md` + `animation-rules.md`
- **State Management** → `riverpod-rules.md`
- **Models & Codegen** → `freezed-model-rules.md`
- **Backend & Data** → `firebase-rules.md` + `repository-rules.md` + `data-loading-rules.md`
- **Error Handling & Logs** → `error-handling-rules.md` + `logging-rules.md`
- **Security & Performance** → `security-rules.md` + `performance-rules.md`
- **Testing & Dependencies** → `testing-rules.md` + `dependency-rules.md`
- **Git & PRs** → `git-rules.md`
- **Code Review** → `code-review-checklist.md`
- **Task Completion** → `definition-of-done.md`

## Enforcement

- AI agents must not ignore these rules.
- Rules apply to both human developers and AI-generated code.
- Product decisions override generic coding preferences.
- Existing architecture must be followed before introducing alternatives.
