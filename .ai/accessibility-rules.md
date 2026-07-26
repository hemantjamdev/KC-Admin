# Accessibility Rules

- Provide semantic labels (`Semantics` / `tooltip`) for icon-only buttons and meaningful image controls.
- Decorative images must be marked with `excludeFromSemantics: true` to prevent screen-reader clutter.
- Maintain WCAG AA color contrast standards for text over background surfaces.
- Ensure text scales gracefully with OS text scaling settings without clipping container bounds.
- Touch tap targets must be at least 48x48 logical pixels.
- Text fields must feature clear visual labels and accessible validation error messages.
- Loading indicators must provide screen-reader announcements when appropriate.
