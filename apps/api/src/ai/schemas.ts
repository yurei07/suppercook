import { z } from 'zod';

/**
 * JSON-схемы для Structured Output.
 * Ответ модели не принимается на веру — валидируется zod.
 * Это защита от галлюцинаций: некорректный ответ не попадёт к пользователю.
 */

/** Схема одного ингредиента, распознанного на фото */
export const recognizedItemSchema = z.object({
  name: z.string().min(1).max(120),
  quantity: z.number().positive().max(100_000),
  unit: z.enum(['g', 'ml', 'pcs']),
  confidence: z.number().min(0).max(1).default(0.8),
});

/** Ответ модели на распознавание фото */
export const recognitionSchema = z.object({
  items: z.array(recognizedItemSchema).max(40),
  summary: z.string().max(500).default(''),
});
export type RecognitionOutput = z.infer<typeof recognitionSchema>;

/** Ингредиент в сгенерированном рецепте */
export const generatedIngredientSchema = z.object({
  name: z.string().min(1).max(120),
  quantity: z.number().positive().max(100_000),
  unit: z.enum(['g', 'ml']),
});

/** Сгенерированный рецепт — валидируется целиком */
export const generatedRecipeSchema = z.object({
  title: z.string().min(3).max(200),
  description: z.string().min(3).max(600),
  servings: z.number().int().min(1).max(12).default(2),
  timeMinutes: z.number().int().min(1).max(600),
  difficulty: z.enum(['easy', 'medium', 'hard']).default('easy'),
  ingredients: z.array(generatedIngredientSchema).min(2).max(25),
  steps: z.array(z.string().min(3).max(800)).min(2).max(20),
  nutrition: z.object({
    kcal: z.number().min(0).max(5000),
    protein: z.number().min(0).max(500),
    carbs: z.number().min(0).max(800),
    fat: z.number().min(0).max(500),
  }),
  tags: z.array(z.string().min(1).max(40)).max(10).default([]),
});

export const generatedRecipesSchema = z.object({
  recipes: z.array(generatedRecipeSchema).min(1).max(5),
});
export type GeneratedRecipesOutput = z.infer<typeof generatedRecipesSchema>;
