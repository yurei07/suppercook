# 🍲 Suppercook

Умный кулинарный помощник: распознаёт продукты на фото, предлагает рецепты из того, что есть в холодильнике, и сам составляет список покупок.

## Что уже работает (MVP-ядро)

| Функция | Статус | Как проверить |
|---|---|---|
| Инвентарь продуктов | ✅ | `POST /inventory` — добавление, объединение дублей, удаление |
| Распознавание фото | ✅ (mock) | `POST /inventory/recognize` — возвращает распознанные продукты |
| AI-генерация рецептов | ✅ (mock) | `POST /recipes/suggest` — 3 рецепта с расчётом нехватки |
| Умный список покупок | ✅ | `POST /shopping/from-recipe` — добавляет **только то, чего не хватает** |
| Режим готовки | ✅ | Мобильное приложение, пошаговые инструкции |
| КБЖУ в рецептах | ✅ | Поле `nutrition` в ответе |
| Недельное планирование | ⏳ v1.2 | — |
| Сообщество и чаты | ⏳ v2.0 | — |

**Важно про AI:** сейчас работает **mock-провайдер** — он не требует API-ключа и возвращает осмысленные данные. Чтобы подключить настоящий GPT, см. раздел «Подключение OpenAI».

## Структура проекта

```
suppercook/
├── apps/
│   ├── api/                  # Backend: NestJS + TypeScript
│   │   └── src/
│   │       ├── ai/           # AI-слой (провайдеры, схемы zod, промпты)
│   │       ├── inventory/    # Инвентарь пользователя
│   │       ├── recipes/      # Генерация и расчёт рецептов
│   │       ├── shopping/     # Умный список покупок
│   │       └── common/       # Доменные типы, единицы измерения
│   └── mobile/               # Frontend: React Native + Expo
│       └── src/
│           ├── api/          # Клиент API
│           └── screens/      # 4 экрана MVP
├── docs/                     # Продуктовая документация
└── package.json              # npm workspaces
```

## Быстрый старт

### 1. Установка зависимостей

```bash
npm install
```

### 2. Запуск API

```bash
npm run api
# → 🍲 Suppercook API ready → http://localhost:3000
```

Проверка:

```bash
curl http://localhost:3000/health
```

### 3. Запуск мобильного приложения

```bash
npm run mobile
```

Откройте Expo Go на телефоне и отсканируйте QR-код (устройство должно быть в той же сети), либо нажмите `a` для Android-эмулятора / `i` для iOS-симулятора.

> **Важно:** эмулятор Android ходит на `10.0.2.2:3000`, iOS-симулятор — на `localhost:3000`. Это уже настроено в `src/api/client.ts`. Для реального устройства укажите IP компьютера:
>
> ```bash
> EXPO_PUBLIC_API_URL=http://192.168.x.x:3000 npm run mobile
> ```

### 4. Тесты

```bash
npm test          # 17 тестов: логика умного списка + единицы измерения
npm run build:api # компиляция TypeScript
```

## API

| Метод | Путь | Описание |
|---|---|---|
| GET | `/health` | Проверка живости |
| GET | `/inventory` | Список продуктов |
| POST | `/inventory` | Добавить продукт `{name, quantity, unit}` |
| PATCH | `/inventory/:id` | Изменить |
| DELETE | `/inventory/:id` | Удалить |
| POST | `/inventory/recognize` | Распознать фото `{imageBase64, mimeType}` |
| POST | `/recipes/suggest` | Рецепты из инвентаря `{request?, allergens?, preferences?}` |
| GET | `/shopping` | Список покупок |
| POST | `/shopping/from-recipe` | Добавить недостающее `{missingIngredients[], recipeId?}` |
| POST | `/shopping/items` | Добавить вручную |
| PATCH | `/shopping/items/:id` | Отметить купленным `{checked}` |
| DELETE | `/shopping/items/:id` | Удалить |
| DELETE | `/shopping/checked` | Очистить купленное |

Идентификация пользователя — заголовок `x-user-id` (заглушка для MVP).

### Пример: полный цикл

```bash
H='Content-Type: application/json'
U='x-user-id: demo'

# 1. Положить продукты в «холодильник»
curl -X POST localhost:3000/inventory -H "$H" -H "$U" \
  -d '{"name":"яйцо","quantity":6,"unit":"pcs"}'

# 2. Получить рецепты
curl -X POST localhost:3000/recipes/suggest -H "$H" -H "$U" -d '{}'

# 3. Добавить недостающее в список покупок
curl -X POST localhost:3000/shopping/from-recipe -H "$H" -H "$U" \
  -d '{"missingIngredients":["сыр (60 g)"],"recipeId":"r1"}'
```

## Подключение OpenAI

По умолчанию используется mock-провайдер (не требует ключа, подходит для разработки).

```bash
cd apps/api
cp .env.example .env
# в .env установить:
# AI_PROVIDER=openai
# OPENAI_API_KEY=sk-...
npm run start:dev
```

При недоступности OpenAI происходит **автоматический fallback на mock** — пользователь не видит ошибку.

### Как защищено от галлюцинаций AI

1. **JSON-схема + zod**: ответ модели не принимается на веру, некорректная структура отклоняется.
2. **Аллергены фильтруются кодом**, а не промптом — промпт можно «уговорить», код нельзя (`ai.service.ts → filterAllergens`).
3. **Нехватка считается на сервере** (`recipes.service.ts → withMissing`), а не доверяется модели.
4. **Кэш 30 минут** — повторяющиеся запросы не стоят денег.
5. **Retry + fallback** — временные ошибки не роняют пользовательский сценарий.

## Документация

- [Структура MVP](docs/01-mvp-scope.md) — приоритеты, метрики, дорожная карта
- [Архитектура](docs/02-architecture.md) — стек, схема, AI-слой
- [User Flow](docs/03-user-flow.md) — путь пользователя до первого блюда
- [Подводные камни](docs/04-risks.md) — технические и продуктовые риски

## Известные ограничения MVP

- **Хранение в памяти**: данные сбрасываются при перезапуске API. Замена на PostgreSQL + Prisma — задача v1.1.
- **Аутентификация**: заглушка через заголовок `x-user-id`.
- **mock-провайдер**: распознавание фото возвращает фиксированный набор продуктов.
- **Сообщество, чаты, недельное планирование** — в плане на v1.1–v2.0.

## Стек

**Mobile:** React Native + Expo · **Backend:** NestJS · **Валидация:** class-validator + zod · **AI:** OpenAI GPT (мультимодальный) с mock-fallback · **Тесты:** Jest
