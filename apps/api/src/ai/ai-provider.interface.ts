import { RecognitionOutput, GeneratedRecipesOutput } from './schemas';

/**
 * Контекст пользователя, передаваемый в AI-слой.
 * allergens обрабатывается ОТДЕЛЬНО от промпта — фильтрация идёт кодом.
 */
export interface AiUserContext {
  userId: string;
  allergens: string[];
  preferences: string[];
  diet?: string;
}

export interface RecipeGenerationInput {
  context: AiUserContext;
  /** Инвентарь в нормализованном виде: имя, количество, единица */
  inventory: Array<{ name: string; quantity: number; unit: string }>;
  /** Дополнительный запрос пользователя: "что быстро?", "вегетарианское" и т.п. */
  request?: string;
}

/**
 * Единый интерфейс AI-провайдера.
 * Меняем OpenAI на Anthropic (или на свою модель) — не трогая остальной код.
 */
export interface AiProvider {
  readonly name: string;

  /** Распознавание ингредиентов на фотографии */
  recognizeIngredients(
    imageBase64: string,
    mimeType: string,
  ): Promise<RecognitionOutput>;

  /** Генерация рецептов строго из имеющихся ингредиентов */
  generateRecipes(input: RecipeGenerationInput): Promise<GeneratedRecipesOutput>;
}
