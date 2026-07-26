# Design System Rules - KC-Admin

## Brand Foundation

- **Brand**: Kapada Creation
- **Tagline**: We Care What You Wear.
- **Primary Color**: `#1D3F32` (Deep Forest Emerald)

## Admin App Experience

- The Admin App UI must feel:
  - **Fast**
  - **Clear**
  - **Operational**
  - **Simple**
  - **Reliable**
  - **Efficient**

## Design System Guidelines

- All colors must be sourced from the centralized theme system (`Theme.of(context).colorScheme`).
- Do not hard-code raw hex or RGB colors inside widget files.
- Use semantic color names: `primary`, `onPrimary`, `surface`, `surfaceElevated`, `textPrimary`, `textSecondary`, `error`, `divider`, `unavailable`.
- Typography must derive from `Theme.of(context).textTheme`.
- Spacing, border-radius, and shadows must use defined constants.
- Admin App layout is structured, dense, and operational (data tables, scannable list tiles, clear status badges, efficient form layouts).
- Current theme files in `lib/src/app/theme/` serve as temporary Material 3 foundations until the dedicated design-system task.
