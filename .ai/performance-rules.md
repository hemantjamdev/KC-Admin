# Performance Rules

- Avoid unnecessary widget rebuilds. Use `ref.watch(provider.select(...))` when listening to sub-fields.
- Use lazy list builders (`ListView.builder`, `GridView.builder`) for scrollable content.
- Always paginate large data lists using cursor-based pagination (default 20 items).
- Use `CachedNetworkImage` for all remote image loading with placeholder and error fallbacks.
- Load image thumbnails in gallery lists and full-resolution images only on detail views.
- Compress admin uploads (image/design files) client-side before sending.
- Prevent duplicate API and pagination requests.
- Avoid executing heavy synchronous calculations on the UI main thread.
- Dispose animation controllers, scroll controllers, and text editing controllers properly.
- Avoid heavy nested clipping, opacity blending, and complex shadows inside long scrolling lists.
