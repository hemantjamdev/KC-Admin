---
name: Kapada Creation Design System
colors:
  surface: '#f4fbf4'
  surface-dim: '#d4dcd5'
  surface-bright: '#f4fbf4'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eef5ef'
  surface-container: '#e8f0e9'
  surface-container-high: '#e3eae3'
  surface-container-highest: '#dde4de'
  on-surface: '#161d19'
  on-surface-variant: '#404943'
  inverse-surface: '#2b322e'
  inverse-on-surface: '#ebf3ec'
  outline: '#707973'
  outline-variant: '#c0c9c1'
  surface-tint: '#31694f'
  primary: '#003a26'
  on-primary: '#ffffff'
  primary-container: '#18523a'
  on-primary-container: '#8ac4a5'
  inverse-primary: '#99d3b4'
  secondary: '#605e5a'
  on-secondary: '#ffffff'
  secondary-container: '#e6e2dc'
  on-secondary-container: '#666460'
  tertiary: '#003b25'
  on-tertiary: '#ffffff'
  tertiary-container: '#005436'
  on-tertiary-container: '#75c99d'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b4f0cf'
  primary-fixed-dim: '#99d3b4'
  on-primary-fixed: '#002113'
  on-primary-fixed-variant: '#165038'
  secondary-fixed: '#e6e2dc'
  secondary-fixed-dim: '#c9c6c1'
  on-secondary-fixed: '#1c1c18'
  on-secondary-fixed-variant: '#484743'
  tertiary-fixed: '#9ff4c6'
  tertiary-fixed-dim: '#84d7ab'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005235'
  background: '#f4fbf4'
  on-background: '#161d19'
  surface-variant: '#dde4de'
typography:
  display-lg:
    fontFamily: Playfair Display
    fontSize: 64px
    fontWeight: '700'
    lineHeight: 72px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Playfair Display
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
  headline-lg:
    fontFamily: Playfair Display
    fontSize: 40px
    fontWeight: '600'
    lineHeight: 48px
  headline-lg-mobile:
    fontFamily: Playfair Display
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-md:
    fontFamily: Playfair Display
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Montserrat
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Montserrat
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Montserrat
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Montserrat
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.03em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-max: 1280px
  gutter: 24px
  margin-mobile: 20px
  margin-desktop: 64px
  section-gap: 120px
---

## Brand & Style

This design system embodies the intersection of high-end fashion and artisanal craftsmanship. It is tailored for a premium women's boutique and bespoke stitching studio, focusing on elegance, femininity, and the precision of tailoring. 

The aesthetic is **Editorial Minimalism** mixed with **Tactile Luxury**. It prioritizes generous whitespace to allow high-quality garment photography to breathe, creating a digital environment that feels as curated as a physical atelier. Visual depth is achieved through a soft layering of warm ivory and cream surfaces rather than heavy shadows. The "handcrafted" narrative is reinforced through delicate line work, subtle stitch-inspired motifs, and a sophisticated typographic hierarchy that balances heritage with modernity.

The emotional goal is to evoke feelings of exclusivity, trust in craftsmanship, and timeless beauty.

## Colors

The color palette is anchored by a deep, botanical green that signifies heritage and quality. This is balanced by a foundation of warm, paper-like neutrals—Ivory and Soft Cream—which provide a more inviting and premium feel than pure digital white.

- **Primary Green Palette:** Used for brand identity, primary actions, and key interactive elements. The darker shades provide authority, while the lighter accents add vibrancy to buttons and links.
- **Surface Strategy:** Use `#FFFBF5` (Warm Ivory) as the global page background. Use `#F7F1E7` (Soft Cream) for secondary sections or container surfaces to create subtle depth.
- **Accents:** Gold is used sparingly for highlights, testimonials, or "Bespoke" service indicators. Functional colors (Success/Error) are tuned to remain harmonious with the green-heavy palette.

## Typography

This system utilizes a high-contrast typographic pairing to signal both "Boutique" (Serif) and "Service" (Sans-Serif).

- **Headlines & Editorials:** Use **Playfair Display**. It should be used for large hero statements, collection titles, and section headers. Keep tracking tight on large sizes.
- **Body & Interface:** Use **Montserrat**. Its geometric clarity balances the ornate nature of the serif. Use the `400` weight for long-form reading and `600` for labels or buttons.
- **Stylistic Note:** Labels should often be set in uppercase with slight letter-spacing to enhance the luxury feel.

## Layout & Spacing

The layout follows an **Editorial Fluid Grid**. It is designed to prioritize imagery over dense information architecture.

- **Grid Model:** A 12-column grid on desktop with generous 64px outer margins.
- **Section Spacing:** Use large vertical gaps (up to 120px) between major sections to maintain a sense of calm and exclusivity.
- **Reflow:** On mobile, margins reduce to 20px, and the grid collapses to a single column for text, with 2-column layouts reserved for product galleries.
- **Visual Rhythm:** Align elements to a consistent 8px baseline, but allow images to break the grid occasionally for a more "magazine-style" feel.

## Elevation & Depth

In alignment with the premium boutique feel, elevation is achieved through **Tonal Layering** rather than dramatic shadows.

- **Surfaces:** Use the Ivory background as the base. Content cards should use the White surface with a very subtle, diffused shadow: `0px 4px 20px rgba(29, 36, 32, 0.04)`.
- **Borders:** Use the `#DCE4DF` border color for structural separation.
- **Tailoring Details:** For "Stitching" services or premium details, use a **Dashed Border** (2px dash, 2px gap) in the Primary Green to mimic needlework.
- **Glassmorphism:** Apply a light backdrop blur (12px) with 80% opacity on navigation bars to maintain context as the user scrolls through vibrant imagery.

## Shapes

The shape language is soft and organic, mirroring the flow of fabric. 

- **Primary Radius:** A default of `0.5rem` (8px) is used for inputs and small buttons.
- **Large Components:** Cards, Image containers, and Modals should use `rounded-xl` (1.5rem / 24px) to emphasize the soft, premium aesthetic.
- **Pill Shapes:** Use for chips, tags (e.g., "In Stock"), and secondary buttons.

## Components

- **Buttons:**
  - *Primary:* Solid `#18523A` with white text. High-contrast, rectangular with slightly rounded corners (8px).
  - *Secondary:* Outlined in Primary Green with a 1.5px stroke. Use for less critical actions like "View Details."
  - *Text Action:* Playfair Display italicized for a "Discover More" link feel.
- **Cards (Product/Style):**
  - Use the `surface-white` background with `rounded-xl` corners.
  - Images should have a subtle zoom-in transition on hover.
  - Price and title should be center-aligned to mimic boutique tags.
- **Input Fields:**
  - Minimalist style: Only a bottom border of 1.5px in `#DCE4DF`. Upon focus, the border transitions to the Primary Green.
- **Stitch Accents:**
  - Use a custom separator component: a horizontal line with a small "needle" or "dot" icon in the center to signify a break in the garment narrative.
- **Chips & Tags:**
  - Small, pill-shaped elements using the `#F7F1E7` (Cream) background and `#1D2420` text. Used for fabric types (e.g., "Pure Silk", "Hand-stitched").