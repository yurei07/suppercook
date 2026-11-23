import { BadRequestException, Injectable } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { PrismaService } from '../prisma/prisma.service';
import { ReplaceWeekDto, UpsertMealDto } from './planner.dto';

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

  private parseRecipe(json: string): Record<string, unknown> {
    try {
      return JSON.parse(json) as Record<string, unknown>;
    } catch {
      return {};
    }
  }
}
