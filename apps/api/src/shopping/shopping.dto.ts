import {
  IsArray,
  IsBoolean,
  IsIn,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

/** POST /shopping/items — добавить позицию вручную */
export class AddShoppingItemDto {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsNumber()
  @Min(0.01)
  @Max(100_000)
  quantity!: number;

  @IsIn(['g', 'ml'])
  unit!: 'g' | 'ml';
}

/** PATCH /shopping/items/:id — отметить купленным / не купленным */
export class ToggleShoppingItemDto {
  @IsBoolean()
  checked!: boolean;
}

/** POST /shopping/from-recipe — добавить в список НЕДОСТАЮЩЕЕ из рецепта */
export class AddFromRecipeDto {
  @IsArray()
  @IsString({ each: true })
  @IsNotEmpty({ each: true })
  missingIngredients!: string[];

  @IsOptional()
  @IsString()
  recipeId?: string;
}
