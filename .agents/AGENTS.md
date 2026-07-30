# Kapada Creation (KC) — Engineering & Product Philosophy Rules

This document defines the core product philosophy, architectural standards, design tokens, component reusability guidelines, navigation flow principles, and cross-app data contracts for **Kapada Creation** (`KC-App` Customer App & `KC-Admin` Admin Portal).

---

## 1. Product Philosophy & Brand Identity

- **Kapada Creation (KC) Brand Identity**: Kapada Creation represents boutique fashion, fine stitching craftsmanship, and personalized customer experience. The UI must reflect the Kapada Creation brand with elegance, warmth, and trust.
- **Clarity & Trust**: Customers and Admins must experience zero friction or ambiguity regarding stitching order statuses, design collections, or notifications.
- **Instant Responsiveness**: All actions provide real-time feedback (micro-animations, instant optimistic state, clean toast notifications, live previews).

---

## 2. Architecture Rules

- **Layered Architecture**: Follow Presentation → Application (Riverpod Notifiers) → Domain (Models/Entities) → Data (Firestore Repositories).
- **State Management**:
  - Use `flutter_riverpod` with `NotifierProvider` and `AsyncValue`.
  - Immutable models using explicit `copyWith`, `fromJson`, and `toJson` methods.
- **Cross-App Contract Parity**:
  - `KC-App` and `KC-Admin` must share exact Firestore collection schemas (`stitching_orders`, `notifications`, `products`, `designs`, `shop_profile`, `customers`).
  - Key mapping for customers must support both `firebaseUid` and `id` fallback.

---

## 3. Design & Aesthetic Rules

### Color Tokens (`AppColors`)
- **Background**: Soft luxury off-white / ivory (`#FAF7F2` or `#F9F6F0`).
- **Surface / Card**: Warm crisp white (`#FFFFFF`) with subtle border (`#EAE5DC` or `#E5E0D8`).
- **Text Primary**: Deep charcoal / onyx (`#1A1A1A` or `#222222`).
- **Text Secondary / Muted**: Soft slate / warm grey (`#666666` / `#888888`).
- **Brand Accent / Gold**: Warm champagne / bronze gold (`#C5A880` / `#A67C52`).
- **Status Colors**:
  - **Success / Completed**: Emerald green (`#10B981` / `#2E7D32`).
  - **Warning / In Progress**: Amber gold (`#D97706` / `#E65100`).
  - **Error / Danger**: Rose red (`#DC2626`).

### Typography (`GoogleFonts`)
- **Headings & Titles**: `GoogleFonts.playfairDisplay()` (Bold, serif, luxury feel).
- **Body, Subtitles & Buttons**: `GoogleFonts.montserrat()` (Clean, readable, modern sans-serif).

### Containers & Radii (`AppRadius`)
- **Standard Cards**: `16px` or `20px` border radius with `1px` subtle `surfaceBorder`.
- **Modal Sheets & Dialogs**: `24px` top border radius with `SafeArea` and `viewInsets.bottom` keyboard handling.

---

## 4. Component & Reusability Rules

- **Single Source of Truth**:
  - Never duplicate button, loader, empty state, or error state code inline.
  - Standard components to reuse across features:
    - `AppButton` & `OutlinedButton`
    - `AppToast` (Success, Error, Warning, Info with dynamic borders)
    - `AppLoadingState` & `AppLoadingIndicator`
    - `AppEmptyState`
    - `AppErrorState`
    - `StatusChip`
- **Zero Ad-Hoc Styling**: All spacing must consume `AppSpacing` tokens (`xs: 4`, `sm: 8`, `md: 16`, `lg: 24`, `xl: 32`).

---

## 5. Flow & Navigation Rules

- **Declarative Navigation**: Use `GoRouter` with typed paths (`AppRoutes`).
- **SafeArea & Keyboard Handling**: Every page must utilize `SafeArea` and `PopScope(canPop: context.canPop())` to handle gesture navigation and back buttons smoothly.
- **Destructive Action Safety**: Always prompt an explicit `AlertDialog` before publishing, updating, or deleting critical data.
- **Notifications & Reminders**: Notifications default to immediate publishing (`publishedAt: DateTime.now()`) with clear recipient targeting.

---

## 6. Code Quality & Testing Rules

- **Zero Analyzer Warnings/Errors**: `flutter analyze` must pass cleanly before committing code.
- **Automated Test Coverage**: Run `flutter test` across unit and widget integration tests to ensure data contracts and navigation remain regression-free.
