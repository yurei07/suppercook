/**
 * Доменные типы Suppercook.
 * Единицы измерения: всё, что может быть измерено массой, хранится в граммах.
 * "штуки" (pcs) допустимы только для инвентаря пользователя — на этапе
 * генерации рецептов они конвертируются по средним значениям.
 */

/** Единицы измерения ингредиентов */
export type Unit = 'g' | 'ml' | 'pcs';

/** Элемент инвентаря пользователя (что есть в холодильнике) */
export interface InventoryItem {
  id: string;
  /** Название продукта, как его ввёл пользователь (нормализованное) */
  name: string;
  quantity: number;
  unit: Unit;
  /** ISO-дата добавления */
  addedAt: string;
  /** Откуда пришло: ручной ввод или распознавание фото */
  source: 'manual' | 'photo';
}

/** Ингредиент в рецепте — всегда нормализован к mass/volume */
export interface RecipeIngredient {
  name: string;
  /** Количество на все порции рецепта */
  quantity: number;
  unit: Exclude<Unit, 'pcs'>;
  /** Есть ли у пользователя достаточно (считается при выдаче рецепта) */
  have?: boolean;
}

export type Difficulty = 'easy' | 'medium' | 'hard';

/** КБЖУ одной порции */
export interface Nutrition {
  kcal: number;
  protein: number;
  carbs: number;
  fat: number;
}

/** Готовый рецепт */
export interface Recipe {
  id: string;
  title: string;
  description: string;
  servings: number;
  timeMinutes: number;
  difficulty: Difficulty;
  ingredients: RecipeIngredient[];
  steps: string[];
  nutrition: Nutrition;
  tags: string[];
  /** Ингредиенты, которых не хватает в инвентаре пользователя */
  missingIngredients: string[];
}

/** Позиция умного списка покупок */
export interface ShoppingListItem {
  id: string;
  name: string;
  quantity: number;
  unit: Exclude<Unit, 'pcs'>;
  /** Рецепты, из которых появилась позиция (для дедупликации) */
  recipeIds: string[];
  checked: boolean;
}

/** Результат распознавания фото */
export interface RecognitionResult {
  items: Array<{ name: string; quantity: number; unit: Unit; confidence: number }>;
  /** Что модель "видит" в целом — для отладки */
  summary: string;
}
