import { Injectable } from '@nestjs/common';
import { AiProvider, RecipeGenerationInput } from './ai-provider.interface';
import { GeneratedRecipesOutput, RecognitionOutput } from './schemas';
import { RECIPE_SYSTEM_PROMPT, RECOGNITION_SYSTEM_PROMPT } from './prompts';

/**
 * Mock-провайдер: работает без API-ключа.
 *
 * Зачем нужен:
 * 1. Разработка и тесты без трат на OpenAI.
 * 2. Демо/презентация — приложение всегда отвечает.
 * 3. Fallback, если реальный провайдер упал.
 *
 * Логика генерации — детерминированная: подбираем рецепты
 * по совпадению ингредиентов с инвентарём.
 */
@Injectable()
export class MockAiProvider implements AiProvider {
  readonly name = 'mock';

  async recognizeIngredients(
    _imageBase64: string,
    _mimeType: string,
  ): Promise<RecognitionOutput> {
    // Имитация задержки реальной сети
    await this.delay(400);

    return {
      items: [
        { name: 'яйцо', quantity: 4, unit: 'pcs', confidence: 0.95 },
        { name: 'помидор', quantity: 3, unit: 'pcs', confidence: 0.88 },
        { name: 'молоко', quantity: 500, unit: 'ml', confidence: 0.82 },
        { name: 'сыр', quantity: 150, unit: 'g', confidence: 0.79 },
      ],
      summary: 'Распознано: яйца, помидоры, молоко, сыр. Проверьте и отредактируйте список.',
    };
  }

  async generateRecipes(input: RecipeGenerationInput): Promise<GeneratedRecipesOutput> {
    await this.delay(600);

    const have = new Set(input.inventory.map((i) => i.name));
    const request = (input.request ?? '').toLowerCase();

    // Простой подбор: считаем, сколько ключевых ингредиентов совпало
    const scored = MOCK_RECIPES.map((r) => ({
      recipe: r,
      score: r.keyIngredients.filter((k) => have.has(k)).length,
    }))
      .filter((s) => s.score > 0 || have.size === 0)
      .sort((a, b) => b.score - a.score);

    const selected = scored.slice(0, 3).map((s) => s.recipe);

    return {
      recipes: selected.map((r) => ({
        title: r.title,
        description: r.description,
        servings: r.servings,
        timeMinutes: r.timeMinutes,
        difficulty: r.difficulty,
        ingredients: r.ingredients,
        steps: r.steps,
        nutrition: r.nutrition,
        tags: request ? [...r.tags, 'по запросу'] : r.tags,
      })),
    };
  }

  private delay(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

/** Мини-база рецептов для mock-режима */
const MOCK_RECIPES = [
  {
    keyIngredients: ['яйцо', 'помидор', 'сыр'],
    title: 'Омлет с помидорами и сыром',
    description: 'Пышный омлет на завтрак за 10 минут — классика, которая никогда не надоедает.',
    servings: 2,
    timeMinutes: 10,
    difficulty: 'easy' as const,
    ingredients: [
      { name: 'яйцо', quantity: 240, unit: 'g' as const },
      { name: 'молоко', quantity: 60, unit: 'ml' as const },
      { name: 'помидор', quantity: 150, unit: 'g' as const },
      { name: 'сыр', quantity: 60, unit: 'g' as const },
      { name: 'масло сливочное', quantity: 15, unit: 'g' as const },
    ],
    steps: [
      'Разбейте яйца в миску, добавьте молоко и щепотку соли, взбейте вилкой до однородности.',
      'Разогрейте сковороду со сливочным маслом на среднем огне 1-2 минуты.',
      'Вылейте яичную смесь, уменьшите огонь и готовьте 3 минуты без помешивания.',
      'Выложите нарезанные помидоры и тёртый сыр, накройте крышкой и готовьте ещё 2-3 минуты.',
      'Снимите с огня, дайте постоять минуту и подавайте.',
    ],
    nutrition: { kcal: 320, protein: 22, carbs: 6, fat: 23 },
    tags: ['завтрак', 'быстро', 'просто'],
  },
  {
    keyIngredients: ['яйцо', 'помидор'],
    title: 'Яичница с помидорами',
    description: 'Быстрый ужин из минимального набора продуктов — жареные яйца с сочными помидорами.',
    servings: 1,
    timeMinutes: 8,
    difficulty: 'easy' as const,
    ingredients: [
      { name: 'яйцо', quantity: 180, unit: 'g' as const },
      { name: 'помидор', quantity: 120, unit: 'g' as const },
      { name: 'масло растительное', quantity: 15, unit: 'ml' as const },
    ],
    steps: [
      'Разогрейте сковороду с растительным маслом на среднем огне.',
      'Нарежьте помидоры дольками и обжарьте 2-3 минуты.',
      'Вбейте яйца между ломтиками, посолите.',
      'Готовьте под крышкой 3-4 минуты, пока белок схватится, а желток останется жидким.',
    ],
    nutrition: { kcal: 290, protein: 19, carbs: 5, fat: 21 },
    tags: ['ужин', 'быстро', 'бюджет'],
  },
  {
    keyIngredients: ['молоко', 'сыр'],
    title: 'Сырный крем-суп',
    description: 'Нежный суп из сыра и молока — согреет и насытит, готовится за 20 минут.',
    servings: 2,
    timeMinutes: 20,
    difficulty: 'easy' as const,
    ingredients: [
      { name: 'сыр', quantity: 200, unit: 'g' as const },
      { name: 'молоко', quantity: 500, unit: 'ml' as const },
      { name: 'картофель', quantity: 300, unit: 'g' as const },
      { name: 'лук', quantity: 100, unit: 'g' as const },
      { name: 'масло сливочное', quantity: 20, unit: 'g' as const },
    ],
    steps: [
      'Очистите и нарежьте картофель кубиками, лук — мелко.',
      'Обжарьте лук на сливочном масле 3 минуты до прозрачности.',
      'Добавьте картофель, залейте 500 мл воды и варите 15 минут до мягкости.',
      'Добавьте молоко и натёртый сыр, перемешивайте на медленном огне, пока сыр не расплавится.',
      'Пробейте блендером до однородности и подавайте.',
    ],
    nutrition: { kcal: 410, protein: 19, carbs: 28, fat: 25 },
    tags: ['обед', 'суп', 'утепляет'],
  },
  {
    keyIngredients: ['помидор'],
    title: 'Томатный соус для пасты',
    description: 'Домашний соус из свежих помидоров — основа для любой пасты.',
    servings: 4,
    timeMinutes: 25,
    difficulty: 'easy' as const,
    ingredients: [
      { name: 'помидор', quantity: 500, unit: 'g' as const },
      { name: 'лук', quantity: 80, unit: 'g' as const },
      { name: 'чеснок', quantity: 10, unit: 'g' as const },
      { name: 'масло растительное', quantity: 20, unit: 'ml' as const },
    ],
    steps: [
      'Ошпарьте помидоры, снимите кожуру и нарежьте мелко.',
      'Обжарьте лук и чеснок на масле 4 минуты.',
      'Добавьте помидоры, тушите на медленном огне 15 минут, помешивая.',
      'Посолите, поперчите и протрите до желаемой консистенции.',
    ],
    nutrition: { kcal: 95, protein: 2, carbs: 9, fat: 5 },
    tags: ['соус', 'вегетарианское', 'заготовка'],
  },
];
