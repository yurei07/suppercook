import { Injectable } from '@nestjs/common';
import { Locale } from '../common/domain.types';
import { AiProvider, RecipeGenerationInput } from './ai-provider.interface';
import { GeneratedRecipesOutput, RecognitionOutput } from './schemas';

interface Localized {
  en: string;
  de: string;
}

interface MockRecipe {
  keyIngredients: { en: string[]; de: string[] };
  title: Localized;
  description: Localized;
  servings: number;
  timeMinutes: number;
  difficulty: 'easy' | 'medium' | 'hard';
  ingredients: Array<{ name: Localized; quantity: number; unit: 'g' | 'ml' }>;
  steps: { en: string[]; de: string[] };
  nutrition: { kcal: number; protein: number; carbs: number; fat: number };
  tags: { en: string[]; de: string[] };
}

/**
 * Mock-провайдер: работает без API-ключа.
 *
 * Зачем нужен:
 * 1. Разработка и тесты без трат на OpenAI.
 * 2. Демо/презентация — приложение всегда отвечает.
 * 3. Fallback, если реальный провайдер упал.
 *
 * Логика генерации — детерминированная: подбираем рецепты
 * по совпадению ингредиентов с инвентарём. Контент полностью EN/DE.
 */
@Injectable()
export class MockAiProvider implements AiProvider {
  readonly name = 'mock';

  async recognizeIngredients(
    _imageBase64: string,
    _mimeType: string,
    locale: Locale,
  ): Promise<RecognitionOutput> {
    // Имитация задержки реальной сети
    await this.delay(400);

    if (locale === 'de') {
      return {
        items: [
          { name: 'Eier', quantity: 4, unit: 'pcs', confidence: 0.95 },
          { name: 'Tomaten', quantity: 3, unit: 'pcs', confidence: 0.88 },
          { name: 'Milch', quantity: 500, unit: 'ml', confidence: 0.82 },
          { name: 'Käse', quantity: 150, unit: 'g', confidence: 0.79 },
        ],
        summary:
          'Erkannt: Eier, Tomaten, Milch, Käse. Prüfe und bearbeite die Liste.',
      };
    }

    return {
      items: [
        { name: 'eggs', quantity: 4, unit: 'pcs', confidence: 0.95 },
        { name: 'tomatoes', quantity: 3, unit: 'pcs', confidence: 0.88 },
        { name: 'milk', quantity: 500, unit: 'ml', confidence: 0.82 },
        { name: 'cheese', quantity: 150, unit: 'g', confidence: 0.79 },
      ],
      summary: 'Detected: eggs, tomatoes, milk, cheese. Review and edit the list.',
    };
  }

  async generateRecipes(
    input: RecipeGenerationInput,
  ): Promise<GeneratedRecipesOutput> {
    await this.delay(600);

    const locale = input.context.locale;
    const have = new Set(
      input.inventory.map((item) => item.name.toLowerCase()),
    );
    const request = (input.request ?? '').toLowerCase();

    // Простой подбор: считаем, сколько ключевых ингредиентов совпало
    const scored = MOCK_RECIPES.map((recipe) => ({
      recipe,
      score: recipe.keyIngredients[locale].filter((key) =>
        have.has(key.toLowerCase()),
      ).length,
    }))
      .filter((entry) => entry.score > 0 || have.size === 0)
      .sort((a, b) => b.score - a.score);

    const selected = scored.length
      ? scored.slice(0, 3).map((entry) => entry.recipe)
      : MOCK_RECIPES.slice(0, 3);

    return {
      recipes: selected.map((recipe) => ({
        title: recipe.title[locale],
        description: recipe.description[locale],
        servings: recipe.servings,
        timeMinutes: recipe.timeMinutes,
        difficulty: recipe.difficulty,
        ingredients: recipe.ingredients.map((ingredient) => ({
          name: ingredient.name[locale],
          quantity: ingredient.quantity,
          unit: ingredient.unit,
        })),
        steps: recipe.steps[locale],
        nutrition: recipe.nutrition,
        tags: request
          ? [
              ...recipe.tags[locale],
              locale === 'de' ? 'auf Anfrage' : 'on request',
            ]
          : recipe.tags[locale],
      })),
    };
  }

  private delay(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

/** Мини-база рецептов для mock-режима (EN/DE) */
const MOCK_RECIPES: MockRecipe[] = [
  {
    keyIngredients: {
      en: ['eggs', 'tomatoes', 'cheese'],
      de: ['Eier', 'Tomaten', 'Käse'],
    },
    title: {
      en: 'Tomato & Cheese Omelette',
      de: 'Omelett mit Tomaten und Käse',
    },
    description: {
      en: 'A fluffy 10-minute breakfast omelette — a classic that never gets old.',
      de: 'Ein fluffiges Omelett zum Frühstück in 10 Minuten – ein Klassiker, der nie langweilig wird.',
    },
    servings: 2,
    timeMinutes: 10,
    difficulty: 'easy',
    ingredients: [
      { name: { en: 'eggs', de: 'Eier' }, quantity: 240, unit: 'g' },
      { name: { en: 'milk', de: 'Milch' }, quantity: 60, unit: 'ml' },
      { name: { en: 'tomatoes', de: 'Tomaten' }, quantity: 150, unit: 'g' },
      { name: { en: 'cheese', de: 'Käse' }, quantity: 60, unit: 'g' },
      { name: { en: 'butter', de: 'Butter' }, quantity: 15, unit: 'g' },
    ],
    steps: {
      en: [
        'Whisk the eggs with milk and a pinch of salt until smooth.',
        'Heat the butter in a pan over medium heat for 1–2 minutes.',
        'Pour in the egg mixture, lower the heat and cook for 3 minutes without stirring.',
        'Add sliced tomatoes and grated cheese, cover and cook for another 2–3 minutes.',
        'Take off the heat, rest for a minute and serve.',
      ],
      de: [
        'Eier mit Milch und einer Prise Salz glatt verquirlen.',
        'Butter in einer Pfanne bei mittlerer Hitze 1–2 Minuten erhitzen.',
        'Die Eiermasse hineingeben, Hitze reduzieren und 3 Minuten ohne Rühren garen.',
        'Geschnittene Tomaten und geriebenen Käse daraufgeben, abdecken und weitere 2–3 Minuten garen.',
        'Vom Herd nehmen, eine Minute ruhen lassen und servieren.',
      ],
    },
    nutrition: { kcal: 320, protein: 22, carbs: 6, fat: 23 },
    tags: {
      en: ['breakfast', 'quick', 'easy'],
      de: ['Frühstück', 'schnell', 'einfach'],
    },
  },
  {
    keyIngredients: {
      en: ['eggs', 'tomatoes'],
      de: ['Eier', 'Tomaten'],
    },
    title: {
      en: 'Fried Eggs with Tomatoes',
      de: 'Spiegeleier mit Tomaten',
    },
    description: {
      en: 'A quick dinner from a minimal pantry — fried eggs with juicy tomatoes.',
      de: 'Ein schnelles Abendessen aus minimalem Vorrat – Spiegeleier mit saftigen Tomaten.',
    },
    servings: 1,
    timeMinutes: 8,
    difficulty: 'easy',
    ingredients: [
      { name: { en: 'eggs', de: 'Eier' }, quantity: 180, unit: 'g' },
      { name: { en: 'tomatoes', de: 'Tomaten' }, quantity: 120, unit: 'g' },
      {
        name: { en: 'vegetable oil', de: 'Pflanzenöl' },
        quantity: 15,
        unit: 'ml',
      },
    ],
    steps: {
      en: [
        'Heat the oil in a pan over medium heat.',
        'Cut the tomatoes into wedges and fry for 2–3 minutes.',
        'Crack the eggs between the tomato wedges and season.',
        'Cover and cook for 3–4 minutes until the whites set and the yolks stay runny.',
      ],
      de: [
        'Das Öl in einer Pfanne bei mittlerer Hitze erhitzen.',
        'Die Tomaten in Spalten schneiden und 2–3 Minuten anbraten.',
        'Die Eier zwischen den Tomatenspalten aufschlagen und würzen.',
        'Abdecken und 3–4 Minuten garen, bis das Eiweiß fest und das Eigelb noch flüssig ist.',
      ],
    },
    nutrition: { kcal: 290, protein: 19, carbs: 5, fat: 21 },
    tags: {
      en: ['dinner', 'quick', 'budget'],
      de: ['Abendessen', 'schnell', 'günstig'],
    },
  },
  {
    keyIngredients: {
      en: ['milk', 'cheese'],
      de: ['Milch', 'Käse'],
    },
    title: {
      en: 'Creamy Cheese Soup',
      de: 'Cremige Käsesuppe',
    },
    description: {
      en: 'A silky soup made with cheese and milk — warming and filling in 20 minutes.',
      de: 'Eine samtige Suppe aus Käse und Milch – wärmend und sättigend in 20 Minuten.',
    },
    servings: 2,
    timeMinutes: 20,
    difficulty: 'easy',
    ingredients: [
      { name: { en: 'cheese', de: 'Käse' }, quantity: 200, unit: 'g' },
      { name: { en: 'milk', de: 'Milch' }, quantity: 500, unit: 'ml' },
      { name: { en: 'potatoes', de: 'Kartoffeln' }, quantity: 300, unit: 'g' },
      { name: { en: 'onion', de: 'Zwiebel' }, quantity: 100, unit: 'g' },
      { name: { en: 'butter', de: 'Butter' }, quantity: 20, unit: 'g' },
    ],
    steps: {
      en: [
        'Peel and cube the potatoes; finely chop the onion.',
        'Sauté the onion in butter for 3 minutes until translucent.',
        'Add the potatoes, cover with 500 ml water and simmer for 15 minutes until soft.',
        'Add the milk and grated cheese, stirring over low heat until melted.',
        'Blend until smooth and serve.',
      ],
      de: [
        'Kartoffeln schälen und würfeln, Zwiebel fein hacken.',
        'Die Zwiebel 3 Minuten in Butter glasig anschwitzen.',
        'Kartoffeln zugeben, mit 500 ml Wasser bedecken und 15 Minuten weich köcheln.',
        'Milch und geriebenen Käse zugeben und bei niedriger Hitze rühren, bis der Käse geschmolzen ist.',
        'Fein pürieren und servieren.',
      ],
    },
    nutrition: { kcal: 410, protein: 19, carbs: 28, fat: 25 },
    tags: {
      en: ['lunch', 'soup', 'comfort'],
      de: ['Mittagessen', 'Suppe', 'Soulfood'],
    },
  },
  {
    keyIngredients: {
      en: ['tomatoes'],
      de: ['Tomaten'],
    },
    title: {
      en: 'Fresh Tomato Pasta Sauce',
      de: 'Frische Tomatensauce',
    },
    description: {
      en: 'A homemade sauce from fresh tomatoes — the base for any pasta.',
      de: 'Eine hausgemachte Sauce aus frischen Tomaten – die Basis für jede Pasta.',
    },
    servings: 4,
    timeMinutes: 25,
    difficulty: 'easy',
    ingredients: [
      { name: { en: 'tomatoes', de: 'Tomaten' }, quantity: 500, unit: 'g' },
      { name: { en: 'onion', de: 'Zwiebel' }, quantity: 80, unit: 'g' },
      { name: { en: 'garlic', de: 'Knoblauch' }, quantity: 10, unit: 'g' },
      {
        name: { en: 'vegetable oil', de: 'Pflanzenöl' },
        quantity: 20,
        unit: 'ml',
      },
    ],
    steps: {
      en: [
        'Blanch the tomatoes, peel them and chop finely.',
        'Sauté the onion and garlic in oil for 4 minutes.',
        'Add the tomatoes and simmer over low heat for 15 minutes, stirring.',
        'Season and blend to the desired consistency.',
      ],
      de: [
        'Tomaten blanchieren, häuten und fein hacken.',
        'Zwiebel und Knoblauch 4 Minuten in Öl anschwitzen.',
        'Tomaten zugeben und 15 Minuten bei niedriger Hitze köcheln, dabei rühren.',
        'Würzen und bis zur gewünschten Konsistenz pürieren.',
      ],
    },
    nutrition: { kcal: 95, protein: 2, carbs: 9, fat: 5 },
    tags: {
      en: ['sauce', 'vegetarian', 'meal-prep'],
      de: ['Sauce', 'vegetarisch', 'Meal-Prep'],
    },
  },
];
