# 🍲 Suppercook

**Cook with what you already have.**

Suppercook is a cross-platform smart cooking assistant and social kitchen. Photograph the ingredients in your fridge, get recipes that actually fit your pantry, plan your week, and generate a shopping list that buys only what is missing.

![Suppercook home screen](apps/mobile_flutter/docs/screenshots/home.png)

## What works today

| Area | Status | Details |
|---|---|---|
| Flutter client (iOS / Android / Linux) | ✅ | Onboarding, pantry, scan flow, recipe suggestions, cooking mode, shopping list, weekly planner, AI chat UI, profile |
| English / German localization | ✅ | Live language switching without restart, ARB-based, localized API content model |
| Premium dark design system | ✅ | Tokens, serif + sans typography, reusable card/button/badge components |
| Local persistence | ✅ | Pantry, shopping list, weekly plan and profile settings survive a restart |
| Ingredient inventory API | ✅ | Add, merge duplicates, update, delete — `apps/api` |
| Photo recognition | ✅ mock | Returns a realistic ingredient set; OpenAI vision can be enabled |
| AI recipe generation | ✅ mock | 3 recipes with missing-ingredient calculation; OpenAI can be enabled |
| Bilingual API contract | ✅ | `locale: en \| de` for recognition and recipes; localized mock catalog + image keys |
| Smart shopping list | ✅ | Adds only what is missing from the recipe, with deduplication |
| Nutrition (calories / macros) | ✅ | Per-serving values in every recipe response |
| Weekly planning | ⏳ | UI is ready; persistence and API integration are next |
| Community / chat | ⏳ | Chat UI with mock AI replies; real-time community is post-MVP |

> **Important:** the Flutter client currently runs on local demo data. The NestJS API is functional and can be connected next. See [Roadmap](#roadmap).

## Monorepo layout

```
suppercook/
├── apps/
│   ├── api/                  # NestJS + TypeScript backend
│   │   └── src/
│   │       ├── ai/           # AI providers, zod schemas, prompts
│   │       ├── inventory/    # User pantry
│   │       ├── recipes/      # Generation + missing-ingredient logic
│   │       ├── shopping/     # Smart shopping list
│   │       └── common/       # Domain types, units
│   ├── mobile_flutter/       # ✅ Active client: Flutter (iOS, Android, Linux)
│   │   └── lib/
│   │       ├── app/          # Theme, router, adaptive shell
│   │       ├── features/     # Screens by feature
│   │       ├── data/         # Models, Riverpod providers, demo data
│   │       ├── shared/       # Design-system widgets
│   │       └── l10n/         # ARB files EN/DE
│   └── mobile/               # First MVP: React Native + Expo (legacy)
├── docs/                     # Product docs (Russian)
└── package.json              # npm workspaces for API + legacy client
```

## Tech stack

**Client**
- Flutter 3.47 / Dart 3.13 — one codebase for iOS, Android and Linux desktop
- Riverpod 3 for state, `go_router` 18 for navigation
- `shared_preferences` for local settings, `image_picker` for camera/gallery
- ARB localization (`flutter_localizations` + `intl`) with runtime locale switching
- Bundled **DM Serif Display** (editorial headings) and **Inter** (UI)

**Backend**
- NestJS + TypeScript
- class-validator + zod for request and AI-output validation
- Jest for tests
- In-memory storage for the MVP (PostgreSQL + Prisma is the next step)

**AI**
- OpenAI multimodal API with automatic **mock fallback** when no key is configured
- Server-side allergen filtering (the model cannot bypass it)
- Missing ingredients are computed in code, not trusted to the model
- 30-minute response cache and retry logic

## Quick start

### Prerequisites

- Node.js 20+
- Flutter 3.47+ (Linux desktop, Android SDK, or Xcode on macOS for iOS)

### 1. Backend API

```bash
npm install
npm run api
# → http://localhost:3000
curl http://localhost:3000/health
```

The API starts with a mock AI provider and needs no key. To use OpenAI:

```bash
cd apps/api
cp .env.example .env
# AI_PROVIDER=openai
# OPENAI_API_KEY=sk-...
npm run start:dev
```

### 2. Flutter client (active)

```bash
cd apps/mobile_flutter
flutter pub get
flutter run -d linux        # Linux desktop
flutter run -d android      # Android
flutter run -d ios          # iOS (macOS + Xcode)
```

Release build for Linux:

```bash
flutter build linux --release
./build/linux/x64/release/bundle/suppercook
```

Dev shortcut — boot directly into a screen for visual QA:

```bash
./build/linux/x64/release/bundle/suppercook --route=/recipe/salmon_bowl
```

More details: [`apps/mobile_flutter/README.md`](apps/mobile_flutter/README.md).

### 3. Legacy React Native client

```bash
npm run mobile
```

Open Expo Go on your phone and scan the QR code. This was the first MVP; the Flutter client is now the primary target.

## API

| Method | Path | Description |
|---|---|---|
| GET | `/health` | Liveness check |
| GET | `/inventory` | Pantry items |
| POST | `/inventory` | Add item `{name, quantity, unit}` |
| PATCH | `/inventory/:id` | Update item |
| DELETE | `/inventory/:id` | Delete item |
| POST | `/inventory/recognize` | Recognize a photo `{imageBase64, mimeType?, locale?}` |
| POST | `/recipes/suggest` | Recipes from inventory `{request?, allergens?, preferences?, diet?, locale?}` |
| GET | `/shopping` | Shopping list |
| POST | `/shopping/from-recipe` | Add only missing ingredients |
| POST | `/shopping/items` | Add item manually |
| PATCH | `/shopping/items/:id` | Toggle checked |
| DELETE | `/shopping/items/:id` | Delete item |
| DELETE | `/shopping/checked` | Clear bought items |

`locale` accepts `en` or `de` (default `en`) and controls the language of recognized ingredient names, recipe titles, descriptions, steps and tags. Every recipe response also includes an `image` key that the client maps to a local asset.

User identification is a temporary `x-user-id` header for the MVP.

### Example: full cycle

```bash
H='Content-Type: application/json'
U='x-user-id: demo'

# 1. Add ingredients
curl -X POST localhost:3000/inventory -H "$H" -H "$U" \
  -d '{"name":"eggs","quantity":6,"unit":"pcs"}'

# 2. Get recipes in German
curl -X POST localhost:3000/recipes/suggest -H "$H" -H "$U" \
  -d '{"locale":"de"}'

# 3. Add missing ingredients to the shopping list
curl -X POST localhost:3000/shopping/from-recipe -H "$H" -H "$U" \
  -d '{"missingIngredients":["feta (60 g)"],"recipeId":"r1"}'
```

## Localization

- Source strings: `apps/mobile_flutter/lib/l10n/app_en.arb` and `app_de.arb`
- Generated with `flutter gen-l10n`
- The current locale lives in `localeProvider`; changing it rebuilds `MaterialApp.router` in place — **no restart**
- Backend content (recipe names, ingredients) uses a `LocalizedText { en, de }` value object
- Rule: no hard-coded user-facing strings in widgets — only `context.l10n.key`

To add a language: create `app_<code>.arb`, add the `Locale` to `supportedAppLocales`, run `flutter gen-l10n`.

## Design system

- Tokens: `apps/mobile_flutter/lib/app/theme/` (`AppColors`, `AppTypography`, `AppSpacing`)
- Background `#0A0A0A`, surface `#141414`, accent `#F5A623`
- Serif display for dish names and editorial headlines, Inter for functional UI
- Components: `AppPrimaryButton`, `AppGhostButton`, `AppCard`, `AppFilterChip`, `RecipeHeroCard`, `RecipeWideCard`, `RecipeSmallCard`, `MatchBadge`, `AppEmptyState`
- Adaptive navigation: bottom bar on phones, side rail on desktop (≥ 900 px)
- All photography is demo content from Unsplash — see [`apps/mobile_flutter/assets/ATTRIBUTION.md`](apps/mobile_flutter/assets/ATTRIBUTION.md)

## Testing

```bash
# Backend
npm test
npm run build:api

# Flutter client
cd apps/mobile_flutter
flutter analyze
flutter test
```

The Flutter test suite covers the core localization contract (start in English, switch to German live, persist the choice) and local persistence of the pantry, shopping list and weekly planner across provider restarts.

## AI safety

1. **JSON schema + zod** — malformed model output is rejected.
2. **Allergens are filtered in code**, not in the prompt.
3. **Missing ingredients are computed server-side**, never trusted to the model.
4. **30-minute cache** — repeated requests do not cost money.
5. **Retry + mock fallback** — temporary AI outages do not break the user flow.

## Roadmap

| Version | Scope |
|---|---|
| **v1.0 MVP** | Pantry + photo recognition, pantry-aware recipes, cooking mode, smart shopping list |
| **v1.1** | Menu calendar, history, favorites, basic notifications |
| **v1.2** | Weekly plan + calorie/macro targets + weekly shopping list |
| **v2.0** | Community: recipe feed, chats, ratings, full UGC moderation |

Immediate engineering next steps:

1. Replace Flutter demo data with a repository layer over the NestJS API (`dio`, auth tokens), using the new `locale` + `image` contract.
2. Add PostgreSQL + Prisma to the API.
3. Connect real OpenAI vision and recipe generation with budget limits.
4. Add account deletion, privacy policy and AI transparency for the German market (GDPR / AI Act).
5. Ship Linux as Flatpak/AppImage, iOS via TestFlight, Android via Play Internal Testing.

## Documentation

Product docs (Russian):
- [MVP scope](docs/01-mvp-scope.md)
- [Architecture](docs/02-architecture.md)
- [User flow](docs/03-user-flow.md)
- [Risks](docs/04-risks.md)

Flutter client docs:
- [Client README](apps/mobile_flutter/README.md)
- [Android build](apps/mobile_flutter/docs/ANDROID_BUILD.md)

## Status

This is an actively developed MVP. The Flutter interface is feature-complete for the core loop and runs on Linux today. Pantry, shopping list, weekly plan and profile settings persist locally. AI and authentication are intentionally mocked until the API integration milestone; server-side persistence is still in-memory.
