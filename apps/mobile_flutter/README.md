# Suppercook — Flutter client

Cross-platform Suppercook client: iOS, Android and Linux desktop from a single Flutter codebase.

> This is the **new Flutter client**. The original React Native/Expo MVP lives in `apps/mobile` and is untouched. The NestJS API lives in `apps/api`.

## Implemented

- **Onboarding**: EN/DE language picker with live preview, three intro slides, auth stub, personalization (diet, allergies, goal, calories).
- **Home**: greeting, hero recipe carousel, quick actions, recommended recipes, pantry matches.
- **Ingredient scan**: camera/gallery on mobile, file upload on Linux, mock AI analysis, editable detected-ingredient list.
- **Recipe suggestions**: pantry match %, filters, missing-ingredient badges.
- **Recipe detail**: photo, macros, “you have / you need”, steps, add-missing-to-shopping-list.
- **Cooking mode**: step-by-step flow, per-step timer, cooked-meals counter.
- **Smart shopping list**: categories, progress, “already at home”, manual items.
- **Weekly planner**: week strip, breakfast/lunch/dinner, plan generation, meal picker.
- **Pantry**: grouped by category, add and remove products.
- **AI chat**: mock answers grounded in the current pantry, with a link to the recipe.
- **Profile**: language, diet, allergies, goal, notifications, about, reset demo data.
- **Responsive layout**: bottom navigation on phones, side rail on Linux (≥ 900 px).
- **Localization**: EN/DE with instant switching, no restart.
- **Local persistence**: pantry, shopping list, weekly plan and profile settings survive a restart.

## Run

```bash
cd apps/mobile_flutter
flutter pub get
flutter run -d linux          # Linux desktop
flutter run -d android        # Android (requires Android SDK)
flutter run -d ios            # iOS (macOS + Xcode only)
```

Linux release:

```bash
flutter build linux --release
./build/linux/x64/release/bundle/suppercook
```

Visual QA shortcut — boot straight into any route:

```bash
./build/linux/x64/release/bundle/suppercook --route=/recipe/salmon_bowl
```

## Architecture

```
lib/
├── app/                 # bootstrap, router, shell, theme
│   ├── theme/           # colors, typography, spacing, ThemeData
│   ├── app_shell.dart   # bottom nav / desktop rail
│   └── router.dart      # go_router, StatefulShellRoute
├── core/                # providers, locale controller, prefs, extensions
├── data/
│   ├── models/          # Recipe, Ingredient, LocalizedText, ShoppingItem
│   ├── providers/       # Riverpod state (pantry, shopping, recipes, user)
│   └── mock_data.dart   # demo content until the API is connected
├── features/            # feature-first screens
│   ├── onboarding/ auth/ home/ scan/ recipes/ shopping/ planner/
│   └── pantry/ chat/ profile/
├── shared/widgets/      # design-system components
└── l10n/                # ARB (EN/DE) + generated AppLocalizations
```

**Stack:** Flutter 3.47 · Dart 3.13 · Riverpod 3 · go_router 18 · shared_preferences · intl · image_picker.

## Localization

- Sources: `lib/l10n/app_en.arb`, `lib/l10n/app_de.arb`.
- Generation: `flutter gen-l10n` (config in `l10n.yaml`).
- Current language: `localeProvider` (`lib/core/locale_controller.dart`). Changing the locale rebuilds `MaterialApp.router` in place — no restart.
- Backend content (recipe and ingredient names) is localized through `LocalizedText { en, de }`.
- Rule: no hard-coded user-facing strings in code — only `context.l10n.key`.

Add a language: create `app_<code>.arb`, add the `Locale` to `supportedAppLocales`, run `flutter gen-l10n`.

## Design system

- Tokens: `lib/app/theme/` (`AppColors`, `AppTypography`, `AppSpacing`).
- Fonts: **DM Serif Display** for dish headings, **Inter** for UI (bundled in `assets/fonts`).
- Palette: `#0A0A0A` background, `#141414` surface, `#F5A623` accent.
- Components: `AppPrimaryButton`, `AppGhostButton`, `AppCard`, `AppFilterChip`, `RecipeHeroCard`, `RecipeWideCard`, `RecipeSmallCard`, `MatchBadge`, `AppEmptyState`, `AppPageHeader`.

## What is mocked

1. **AI recognition** returns a fixed ingredient set (`MockData.scanDetected`) after a photo is selected.
2. **AI chat** answers from a template based on the top pantry recipe.
3. **Auth** is a stub; no data leaves the device.
4. **State is local-first**: pantry, shopping list, weekly plan and profile prefs persist in SharedPreferences. There is no server sync yet.
5. **Camera on Linux** is unavailable — file upload is used instead.

Next step: connect `apps/api` (NestJS) by replacing `MockData` with a repository layer, adding `dio`, auth tokens and the real `/inventory`, `/recipes/suggest`, `/shopping` endpoints.

## Tests

```bash
flutter analyze
flutter test
```

Tests cover the core localization contract (start in English → switch to German live → persist the choice) and local persistence of the pantry, shopping list and weekly planner across provider restarts.

## Assets

Food photography is demo content from Unsplash — see `assets/ATTRIBUTION.md`. Replace it with licensed brand photography before production.
