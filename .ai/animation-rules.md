# Animation Rules

- Animations must communicate visual hierarchy, state changes, or navigation continuity.
- Keep all motion subtle, smooth, and performance-conscious (standard duration: 150ms–300ms).
- Prefer built-in Flutter implicit and explicit animations.
- Use `flutter_animate` only when it enhances visual clarity without adding clutter.
- Use `AnimatedSwitcher` for state replacements and `AnimatedSize` for expanding sections.
- Page transitions use subtle fade and vertical slide (`FadeSlideTransition`).
- Avoid long, exaggerated animations, excessive bounces, or animating every single widget.
- Do not introduce animations that delay user interaction or slow down task completion.
- Maintain a consistent 60 FPS / 120 FPS frame rate on mid-range Android and iOS devices.
