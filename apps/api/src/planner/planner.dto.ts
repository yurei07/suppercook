import {
  ArrayMaxSize,
  IsArray,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsObject,
  IsString,
  Matches,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

/** ISO-дата понедельника, с которого начинается неделя плана. */
export const WEEK_PATTERN = /^\d{4}-\d{2}-\d{2}$/;

export const MEAL_SLOTS = ['breakfast', 'lunch', 'dinner'] as const;

/**
 * Полный снимок рецепта с клиента (формат Recipe.toJson).
 * Сервер не знает домен рецептов — проверяет минимум и хранит как есть.
 */
export class RecipeSnapshotDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  id!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  title!: string;
}

export class UpsertMealDto {
  @Matches(WEEK_PATTERN, { message: 'week must be YYYY-MM-DD (a Monday)' })
  week!: string;

  @IsInt()
  @Min(0)
  @Max(6)
  day!: number;

  @IsIn(MEAL_SLOTS)
  slot!: string;

  @IsObject()
  @ValidateNested()
  @Type(() => RecipeSnapshotDto)
  recipe!: RecipeSnapshotDto;
}

export class ReplaceWeekDto {
  @Matches(WEEK_PATTERN, { message: 'week must be YYYY-MM-DD (a Monday)' })
  week!: string;

  @IsArray()
  @ArrayMaxSize(21)
  @ValidateNested({ each: true })
  @Type(() => RecipeSnapshotDto)
  meals!: UpsertMealDto[];
}

/**
 * Пул рецептов с клиента — сервер собирает из него сбалансированную неделю.
 */
export class GenerateWeekDto {
  @Matches(WEEK_PATTERN, { message: 'week must be YYYY-MM-DD (a Monday)' })
  week!: string;

  @IsArray()
  @ArrayMaxSize(60)
  @ValidateNested({ each: true })
  @Type(() => RecipeSnapshotDto)
  recipes!: (RecipeSnapshotDto & { tags?: unknown })[];
}
