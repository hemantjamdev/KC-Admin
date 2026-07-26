# UI & UX Rules - KC-Admin

## Shared Principles

- UI must be clean, structured, clear, and efficient.
- Avoid clutter, unnecessary text, or generic template-looking UI.
- All user interactions must provide immediate visual touch feedback (ink response, active state).
- Empty states must explain the situation and suggest a clear next action (`AppEmptyView`).
- Error states must provide an explicit retry option (`AppErrorView`).
- Skeleton loaders or clean loading views (`AppLoadingView`) must preserve screen layout.
- Destructive actions require clear confirmation dialogs.
- Form fields require validation and clear inline error messaging.

## Admin App Specific UX

- Prioritize operational speed and functional clarity.
- Common daily actions (updating status, toggling availability) must require minimal taps.
- Keep forms structured, scannable, and validated.
- Display explicit save progress and image/file upload indicators.
- Bulk actions require clear multi-select state indicators and confirmation dialogs for destructive actions.
- Do not make admin screens visually bloated or unnecessarily decorative.
