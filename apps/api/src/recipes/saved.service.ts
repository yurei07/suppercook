import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { PrismaService } from '../prisma/prisma.service';
import { CookedDto, SaveRecipeDto } from './saved.dto';

export type SavedRecipeView = {
  recipeId: string;
  savedAt: Date;
  recipe: Record<string, unknown>;
};

export type CookedEntryView = {
  recipeId: string;
  title: string;
  cookedAt: Date;
};

function validateRecipe(recipe: SaveRecipeDto['recipe']): string {
  if (
    typeof recipe.id !== 'string' ||
    recipe.id.length === 0 ||
    recipe.id.length > 200 ||
    typeof recipe.title !== 'string' ||
    recipe.title.length === 0
  ) {
    throw new BadRequestException('recipe must have non-empty id and title');
  }
  // Грубая защита от гигантских снимков (клиент шлётRecipe.toJson, это KB)
  if (JSON.stringify(recipe).length > 100_000) {
    throw new BadRequestException('recipe snapshot is too large');
  }
  return recipe.id;
}

@Injectable()
export class SavedRecipesService {
  constructor(private readonly prisma: PrismaService) {}

  // ---------------------------------------------------------------------------
  // Избранное
  // ---------------------------------------------------------------------------

  async listSaved(userId: string): Promise<SavedRecipeView[]> {
    const rows = await this.prisma.savedRecipe.findMany({
      where: { userId },
      orderBy: { savedAt: 'desc' },
    });
    return rows.map((row) => ({
      recipeId: row.recipeId,
      savedAt: row.savedAt,
      recipe: this.parseRecipe(row.recipeJson),
    }));
  }

  async save(userId: string, dto: SaveRecipeDto): Promise<void> {
    const recipeId = validateRecipe(dto.recipe);
    await this.prisma.savedRecipe.upsert({
      where: { userId_recipeId: { userId, recipeId } },
      update: { recipeJson: JSON.stringify(dto.recipe) },
      create: {
        id: randomUUID(),
        userId,
        recipeId,
        recipeJson: JSON.stringify(dto.recipe),
      },
    });
  }

  async unsave(userId: string, recipeId: string): Promise<void> {
    const deleted = await this.prisma.savedRecipe.deleteMany({
      where: { userId, recipeId },
    });
    if (deleted.count === 0) throw new NotFoundException('Recipe not saved');
  }

  async isSaved(userId: string, recipeId: string): Promise<boolean> {
    const count = await this.prisma.savedRecipe.count({
      where: { userId, recipeId },
    });
    return count > 0;
  }

  // ---------------------------------------------------------------------------
  // История приготовленного
  // ---------------------------------------------------------------------------

  async cookedHistory(userId: string): Promise<CookedEntryView[]> {
    const rows = await this.prisma.cookedEntry.findMany({
      where: { userId },
      orderBy: { cookedAt: 'desc' },
      take: 200,
    });
    return rows.map((row) => ({
      recipeId: row.recipeId,
      title: row.title,
      cookedAt: row.cookedAt,
    }));
  }

  async markCooked(userId: string, dto: CookedDto): Promise<void> {
    if (dto.recipeId.length === 0 || dto.recipeId.length > 200) {
      throw new BadRequestException('recipeId is invalid');
    }
    await this.prisma.cookedEntry.create({
      data: {
        id: randomUUID(),
        userId,
        recipeId: dto.recipeId,
        title: dto.title.slice(0, 200),
      },
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
