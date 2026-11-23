import { IsNotEmptyObject, IsObject, IsString } from 'class-validator';

/**
 * Снимок рецепта для избранного — тот же формат Recipe.toJson, что
 * использует планировщик. Сервер проверяет минимум и хранит как есть.
 */
export class SaveRecipeDto {
  @IsObject()
  @IsNotEmptyObject()
  recipe!: Record<string, unknown> & { id?: unknown; title?: unknown };
}

export class CookedDto {
  @IsString()
  recipeId!: string;

  @IsString()
  title!: string;
}
