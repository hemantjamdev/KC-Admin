# Asset Rules

- Use **Phosphor Icons** (`phosphor_flutter`) as the primary icon set across the application.
- Use SVG files (`flutter_svg`) only when a Phosphor icon or branded vector is unavailable.
- Do not import random or overlapping third-party icon libraries.
- Asset files must use clear, descriptive lowercase `snake_case` filenames (e.g. `ic_boutique_marker.svg`).
- Group assets by purpose inside `assets/` (e.g., `icons/`, `images/`, `illustrations/`, `logos/`, `svgs/`).
- Do not check in unused or dead asset files.
- All image assets must be compressed before committing to the repository.
- Register all asset directories explicitly in `pubspec.yaml`.
- Do not use image files for simple shapes or badges that Flutter can render natively.
