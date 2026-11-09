import { Injectable, Logger } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { AiService } from '../ai/ai.service';
import { Recipe, RecipeIngredient, Unit } from '../common/domain.types';
import { pickRecipeImage } from '../common/recipe-images';
import { normalizeIngredientName, toGrams } from '../common/units';
import { InventoryService } from '../inventory/inventory.service';
import { SuggestRecipesDto } from './recipes.dto';

/**
 * Сервис рецептов: оркестрирует инвентарь → AI → расчёт нехватки.
 */
@Injectable()
export class RecipesService {
  private readonly log = new Logger(RecipesService.name);

  constructor(
    private readonly ai: AiService,
    private readonly inventory: InventoryService,
  ) {}

  /**
   * Генерирует рецепты на основе текущего инвентаря пользователя
   * и отмечает, каких ингредиентов не хватает.
   */
  async suggest(userId: string, dto: SuggestRecipesDto): Promise<Recipe[]> {
    const inventory = this.inventory.list(userId);

    const input = {
      context: {
        userId,
        allergens: dto.allergens ?? [],
        preferences: dto.preferences ?? [],
        diet: dto.diet,
        locale: dto.locale ?? 'en',
      },
      inventory: inventory.map((i) => ({
        name: i.name,
        quantity: i.quantity,
        unit: i.unit,
      })),
      request: dto.request,
    };

    const result = await this.ai.generateRecipes(input);

    // Считаем нехватку на сервере — AI это не считает (ненадёжно)
    return result.recipes.map((r, index) =>
      this.withMissing(r, inventory, index),
    );
  }

  /**
   * Отмечает ингредиенты, которых нет в инвентаре (have)
   * и формирует список missingIngredients для UI.
   *
   * Логика: сравниваем в граммах. Для "pcs" считаем по средней массе.
   */
  private withMissing(
    generated: Parameters<typeof this.toRecipe>[0],
    inventory: Array<{ name: string; quantity: number; unit: Unit }>,
    imageIndex: number,
  ): Recipe {
    const recipe = this.toRecipe(generated, imageIndex);
    const missing: string[] = [];

    for (const ing of recipe.ingredients) {
      const haveItem = inventory.find((i) => i.name === normalizeIngredientName(ing.name));
      if (!haveItem) {
        ing.have = false;
        missing.push(`${ing.name} (${ing.quantity} ${ing.unit})`);
        continue;
      }
      const haveGrams = toGrams(haveItem.name, haveItem.quantity, haveItem.unit);
      const needGrams = ing.quantity;
      ing.have = haveGrams >= needGrams;
      if (!ing.have) {
        const diff = Math.round(needGrams - haveGrams);
        missing.push(`${ing.name} (не хватает ${diff} ${ing.unit})`);
      }
    }

    return { ...recipe, missingIngredients: missing };
  }

  private toRecipe(
    generated: {
      title: string;
      description: string;
      servings: number;
      timeMinutes: number;
      difficulty: 'easy' | 'medium' | 'hard';
      ingredients: Array<{ name: string; quantity: number; unit: 'g' | 'ml' }>;
      steps: string[];
      nutrition: { kcal: number; protein: number; carbs: number; fat: number };
      tags: string[];
    },
    imageIndex: number,
  ): Recipe {
    const ingredients: RecipeIngredient[] = generated.ingredients.map((i) => ({
      name: normalizeIngredientName(i.name),
      quantity: i.quantity,
      unit: i.unit,
    }));

    return {
      id: randomUUID(),
      title: generated.title,
      description: generated.description,
      image: pickRecipeImage(generated.title, generated.tags, imageIndex),
      servings: generated.servings,
      timeMinutes: generated.timeMinutes,
      difficulty: generated.difficulty,
      ingredients,
      steps: generated.steps,
      nutrition: generated.nutrition,
      tags: generated.tags,
      missingIngredients: [],
    };
  }
}
