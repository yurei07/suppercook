import { Injectable, Logger, Optional } from '@nestjs/common';
import { AiProvider, RecipeGenerationInput } from './ai-provider.interface';
import { MockAiProvider } from './mock.provider';
import { OpenAiProvider } from './openai.provider';
import { GeneratedRecipesOutput, RecognitionOutput } from './schemas';

/**
 * Оркестратор AI-слоя.
 *
 * Отвечает за:
 * 1. Выбор провайдера (AI_PROVIDER=openai|mock, с fallback на mock).
 * 2. Кэширование повторяющихся запросов (себестоимость).
 * 3. Логирование и трейсинг (что спрашивали, сколько стоило).
 * 4. БЕЗОПАСНОСТЬ: фильтрация аллергенов КОДОМ, после генерации.
 */
@Injectable()
export class AiService {
  private readonly log = new Logger(AiService.name);
  private readonly cache = new Map<string, { value: GeneratedRecipesOutput; expiresAt: number }>();
  private readonly CACHE_TTL_MS = 30 * 60 * 1000; // 30 минут

  private readonly provider: AiProvider;

  constructor(
    private readonly mock: MockAiProvider,
    @Optional() private readonly openai?: OpenAiProvider,
  ) {
    const configured = process.env.AI_PROVIDER ?? 'mock';
    if (configured === 'openai' && openai?.isConfigured) {
      this.provider = openai;
      this.log.log('AI провайдер: openai');
    } else {
      this.provider = mock;
      if (configured === 'openai') {
        this.log.warn('OPENAI_API_KEY не задан — используется mock-провайдер');
      } else {
        this.log.log('AI провайдер: mock (без API-ключа)');
      }
    }
  }

  get providerName(): string {
    return this.provider.name;
  }

  async recognizeIngredients(
    imageBase64: string,
    mimeType = 'image/jpeg',
  ): Promise<RecognitionOutput> {
    const started = Date.now();
    try {
      const result = await this.provider.recognizeIngredients(imageBase64, mimeType);
      this.log.log(
        `recognize: ${result.items.length} items за ${Date.now() - started}ms (${this.provider.name})`,
      );
      return result;
    } catch (error) {
      this.errorLog('recognize', error);
      // Fallback на mock, чтобы пользователь не видел ошибку
      return this.mock.recognizeIngredients(imageBase64, mimeType);
    }
  }

  async generateRecipes(input: RecipeGenerationInput): Promise<GeneratedRecipesOutput> {
    const cacheKey = this.buildCacheKey(input);
    const cached = this.cache.get(cacheKey);
    if (cached && cached.expiresAt > Date.now()) {
      this.log.log('generate: отдано из кэша');
      return cached.value;
    }

    const started = Date.now();
    let result: GeneratedRecipesOutput;
    try {
      result = await this.provider.generateRecipes(input);
    } catch (error) {
      this.errorLog('generate', error);
      result = await this.mock.generateRecipes(input); // fallback
    }

    // ===== ГЛАВНАЯ ЗАЩИТА ОТ АЛЛЕРГЕННОГО РИСКА =====
    // Фильтрация идёт КОДОМ, а не промптом: промпт можно "уговорить",
    // код — нет.
    result = this.filterAllergens(result, input.context.allergens);

    this.cache.set(cacheKey, { value: result, expiresAt: Date.now() + this.CACHE_TTL_MS });
    this.pruneCache();

    this.log.log(`generate: ${result.recipes.length} рецептов за ${Date.now() - started}ms (${this.provider.name})`);
    return result;
  }

  /**
   * Убирает из рецептов ингредиенты-аллергены.
   * Если после фильтрации в рецепте осталось < 2 ингредиентов — рецепт отбрасываем.
   */
  private filterAllergens(
    result: GeneratedRecipesOutput,
    allergens: string[],
  ): GeneratedRecipesOutput {
    if (allergens.length === 0) return result;
    const lower = allergens.map((a) => a.toLowerCase());

    const filtered = result.recipes
      .map((recipe) => ({
        ...recipe,
        ingredients: recipe.ingredients.filter(
          (ing) => !lower.some((a) => ing.name.toLowerCase().includes(a)),
        ),
      }))
      .filter((recipe) => recipe.ingredients.length >= 2);

    if (filtered.length < result.recipes.length) {
      this.log.warn(
        `Фильтрация аллергенов: отброшено ${result.recipes.length - filtered.length} рецептов`,
      );
    }

    return { recipes: filtered };
  }

  private buildCacheKey(input: RecipeGenerationInput): string {
    const inv = input.inventory
      .map((i) => `${i.name}:${i.quantity}:${i.unit}`)
      .sort()
      .join(',');
    return `${input.context.allergens.join(',')}|${input.context.preferences.join(',')}|${input.request ?? ''}|${inv}`;
  }

  private pruneCache(): void {
    const now = Date.now();
    for (const [key, entry] of this.cache) {
      if (entry.expiresAt <= now) this.cache.delete(key);
    }
    // Защита от бесконечного роста
    if (this.cache.size > 500) {
      const firstKey = this.cache.keys().next().value;
      if (firstKey) this.cache.delete(firstKey);
    }
  }

  private errorLog(op: string, error: unknown): void {
    const msg = error instanceof Error ? error.message : String(error);
    this.log.error(`${op}: ошибка (${msg}) → fallback на mock`);
  }
}
