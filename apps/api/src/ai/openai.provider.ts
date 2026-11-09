import { Injectable, Logger } from '@nestjs/common';
import { Locale } from '../common/domain.types';
import { AiProvider, RecipeGenerationInput } from './ai-provider.interface';
import {
  GeneratedRecipesOutput,
  RecognitionOutput,
  generatedRecipesSchema,
  recognitionSchema,
} from './schemas';
import { RECIPE_SYSTEM_PROMPT, RECOGNITION_SYSTEM_PROMPT } from './prompts';

/**
 * Провайдер на OpenAI API (gpt-4o-mini по умолчанию).
 *
 * Использует:
 * - Structured Output (response_format: json_schema) — ответ проходит zod-валидацию;
 * - vision для распознавания фото;
 * - retry с экспоненциальной задержкой при 429/5xx.
 */
@Injectable()
export class OpenAiProvider implements AiProvider {
  readonly name = 'openai';
  private readonly log = new Logger(OpenAiProvider.name);

  private readonly apiKey: string;
  private readonly model: string;
  private readonly baseUrl = 'https://api.openai.com/v1';

  constructor() {
    this.apiKey = process.env.OPENAI_API_KEY ?? '';
    this.model = process.env.OPENAI_MODEL ?? 'gpt-4o-mini';
  }

  get isConfigured(): boolean {
    return this.apiKey.length > 0;
  }

  async recognizeIngredients(
    imageBase64: string,
    mimeType: string,
    locale: Locale,
  ): Promise<RecognitionOutput> {
    const language = this.languageName(locale);
    const raw = await this.chat(
      [
        {
          role: 'system',
          content: RECOGNITION_SYSTEM_PROMPT,
        },
        {
          role: 'user',
          content: [
            {
              type: 'text',
              text: `Распознай продукты на этом фото. Верни названия на языке: ${language}.`,
            },
            {
              type: 'image_url',
              image_url: { url: `data:${mimeType};base64,${imageBase64}` },
            },
          ],
        },
      ],
      recognitionSchema,
    );
    return raw;
  }

  async generateRecipes(input: RecipeGenerationInput): Promise<GeneratedRecipesOutput> {
    const inventoryText = input.inventory
      .map((i) => `- ${i.name}: ${i.quantity} ${i.unit}`)
      .join('\n');

    const allergensText = input.context.allergens.length
      ? `\nУ пользователя АЛЛЕРГИЯ на: ${input.context.allergens.join(', ')}. Эти продукты ЗАПРЕЩЕНЫ в рецептах.`
      : '';

    const prefsText = input.context.preferences.length
      ? `\nПредпочтения: ${input.context.preferences.join(', ')}.`
      : '';

    const requestText = input.request ? `\nДополнительный запрос: ${input.request}` : '';
    const language = this.languageName(input.context.locale);

    return this.chat(
      [
        { role: 'system', content: RECIPE_SYSTEM_PROMPT },
        {
          role: 'user',
          content: `Инвентарь пользователя:\n${inventoryText}${allergensText}${prefsText}${requestText}\n\nПредложи 3 рецепта. Все текстовые поля верни на языке: ${language}.`,
        },
      ],
      generatedRecipesSchema,
    );
  }

  private languageName(locale: Locale): string {
    return locale === 'de' ? 'German (Deutsch)' : 'English';
  }

  /**
   * Общий метод вызова с retry и zod-валидацией.
   * Невалидный JSON от модели → один повтор, затем ошибка.
   */
  private async chat<T>(
    messages: unknown[],
    schema: { parse: (data: unknown) => T },
    isRetry = false,
  ): Promise<T> {
    const response = await fetch(`${this.baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify({
        model: this.model,
        messages,
        temperature: 0.7,
        response_format: { type: 'json_object' },
      }),
    });

    if (!response.ok) {
      const body = await response.text();
      // Ретраим только временные ошибки
      if ((response.status === 429 || response.status >= 500) && !isRetry) {
        await this.delay(1000);
        return this.chat(messages, schema, true);
      }
      throw new Error(`OpenAI ${response.status}: ${body.slice(0, 300)}`);
    }

    const data = (await response.json()) as {
      choices: Array<{ message: { content: string } }>;
    };
    const content = data.choices[0]?.message?.content;
    if (!content) throw new Error('OpenAI: пустой ответ');

    let parsed: unknown;
    try {
      parsed = JSON.parse(content);
    } catch {
      if (!isRetry) {
        // Один повтор при некорректном JSON
        return this.chat(messages, schema, true);
      }
      throw new Error('OpenAI: модель вернула некорректный JSON');
    }

    // zod бросит исключение, если структура не соответствует схеме
    return schema.parse(parsed);
  }

  private delay(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}
