import { BadRequestException, Injectable } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { PrismaService } from '../prisma/prisma.service';
import {
  GenerateWeekDto,
  ReplaceWeekDto,
  UpsertMealDto,
} from './planner.dto';

export type PlannedMealView = {
  id: string;
  day: number;
  slot: string;
  recipeId: string;
  recipe: Record<string, unknown>;
};

function validateRecipeSnapshot(recipe: UpsertMealDto['recipe']): void {
  if (
    typeof recipe.id !== 'string' ||
    recipe.id.length === 0 ||
    typeof recipe.title !== 'string' ||
    recipe.title.length === 0
  ) {
    throw new BadRequestException('recipe must have id and title');
  }
}

@Injectable()
export class PlannerService {
  constructor(private readonly prisma: PrismaService) {}

  /** Неделя плана пользователя. week — ISO-дата понедельника. */
  async getWeek(userId: string, week: string): Promise<PlannedMealView[]> {
    const rows = await this.prisma.plannedMeal.findMany({
      where: { userId, week },
      orderBy: [{ day: 'asc' }, { slot: 'asc' }],
    });
    return rows.map((row) => ({
      id: row.id,
      day: row.day,
      slot: row.slot,
      recipeId: row.recipeId,
      recipe: this.parseRecipe(row.recipeJson),
    }));
  }

  /** Поставить рецепт в слот (day+slot) — перезаписывает существующий. */
  async upsertMeal(userId: string, dto: UpsertMealDto): Promise<void> {
    validateRecipeSnapshot(dto.recipe);
    const recipeJson = JSON.stringify(dto.recipe);
    await this.prisma.plannedMeal.upsert({
      where: {
        userId_week_day_slot: {
          userId,
          week: dto.week,
          day: dto.day,
          slot: dto.slot,
        },
      },
      update: { recipeId: dto.recipe.id, recipeJson },
      create: {
        id: randomUUID(),
        userId,
        week: dto.week,
        day: dto.day,
        slot: dto.slot,
        recipeId: dto.recipe.id,
        recipeJson,
      },
    });
  }

  /** Заменить всю неделю целиком (кнопка «сгенерировать план»). */
  async replaceWeek(userId: string, dto: ReplaceWeekDto): Promise<void> {
    for (const meal of dto.meals) {
      validateRecipeSnapshot(meal.recipe);
    }

    const seen = new Set<string>();
    for (const meal of dto.meals) {
      const key = `${meal.day}:${meal.slot}`;
      if (seen.has(key)) {
        throw new BadRequestException(`Duplicate slot ${key}`);
      }
      seen.add(key);
    }

    await this.prisma.$transaction([
      this.prisma.plannedMeal.deleteMany({ where: { userId, week: dto.week } }),
      ...dto.meals.map((meal) =>
        this.prisma.plannedMeal.create({
          data: {
            id: randomUUID(),
            userId,
            week: dto.week,
            day: meal.day,
            slot: meal.slot,
            recipeId: meal.recipe.id,
            recipeJson: JSON.stringify(meal.recipe),
          },
        }),
      ),
    ]);
  }

  /** Освободить слот. */
  async clearMeal(
    userId: string,
    week: string,
    day: number,
    slot: string,
  ): Promise<void> {
    await this.prisma.plannedMeal.deleteMany({
      where: { userId, week, day, slot },
    });
  }

  /**
   * Сбалансированная неделя из пула рецептов клиента.
   * Правила простые, но лучше захардкоженного плана:
   * - завтрак — из рецептов с тегом breakfast (если такие есть);
   * - обед и ужин не совпадают в один день (если пул позволяет);
   * - ужин не повторяется два дня подряд (если пул позволяет).
   */
  async generateWeek(
    userId: string,
    dto: GenerateWeekDto,
  ): Promise<PlannedMealView[]> {
    const pool = dto.recipes.filter(
      (r) =>
        typeof r.id === 'string' &&
        r.id.length > 0 &&
        typeof r.title === 'string' &&
        r.title.length > 0,
    );
    if (pool.length === 0) {
      throw new BadRequestException('recipes pool is empty');
    }

    const isBreakfast = (recipe: (typeof pool)[number]) =>
      Array.isArray(recipe.tags) &&
      recipe.tags.some((t) => String(t).toLowerCase().includes('breakfast'));
    const breakfastPool = pool.filter(isBreakfast);
    const mainPool = pool;

    const pick = (
      candidates: typeof pool,
      day: number,
      avoid: Array<string | undefined>,
    ): (typeof pool)[number] => {
      const fallback = candidates.length > 0 ? candidates : pool;
      for (let attempt = 0; attempt < fallback.length; attempt++) {
        const candidate = fallback[(day + attempt) % fallback.length];
        if (!avoid.includes(candidate.id) || fallback.length === 1) {
          return candidate;
        }
      }
      return fallback[day % fallback.length];
    };

    const meals: Array<{ day: number; slot: string; recipe: GenerateWeekDto['recipes'][number] }> = [];
    let prevDinnerId: string | undefined;

    for (let day = 0; day < 7; day++) {
      const breakfast = pick(breakfastPool, day, []);
      const lunch = pick(mainPool, day, [breakfast.id]);
      const dinner = pick(mainPool, day + 2, [lunch.id, prevDinnerId]);
      prevDinnerId = dinner.id;

      meals.push(
        { day, slot: 'breakfast', recipe: breakfast },
        { day, slot: 'lunch', recipe: lunch },
        { day, slot: 'dinner', recipe: dinner },
      );
    }

    await this.replaceWeek(userId, {
      week: dto.week,
      meals: meals.map((meal) => ({
        week: dto.week,
        day: meal.day,
        slot: meal.slot,
        recipe: meal.recipe as UpsertMealDto['recipe'],
      })),
    });

    return this.getWeek(userId, dto.week);
  }

  private parseRecipe(json: string): Record<string, unknown> {
    try {
      return JSON.parse(json) as Record<string, unknown>;
    } catch {
      return {};
    }
  }
}
