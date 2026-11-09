import {
  IsArray,
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

/** POST /recipes/suggest — генерация рецептов из инвентаря */
export class SuggestRecipesDto {
  @IsOptional()
  @IsString()
  @MaxLength(300)
  request?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @MaxLength(60, { each: true })
  allergens?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @MaxLength(60, { each: true })
  preferences?: string[];

  @IsOptional()
  @IsIn(['lose_weight', 'maintain', 'gain_weight', 'none'])
  diet?: 'lose_weight' | 'maintain' | 'gain_weight' | 'none';

  /** Язык ответа. По умолчанию — английский. */
  @IsOptional()
  @IsIn(['en', 'de'])
  locale?: 'en' | 'de';
}
