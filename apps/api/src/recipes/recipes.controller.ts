import { Body, Controller, Headers, Post } from '@nestjs/common';
import { SuggestRecipesDto } from './recipes.dto';
import { RecipesService } from './recipes.service';

@Controller('recipes')
export class RecipesController {
  constructor(private readonly recipes: RecipesService) {}

  /**
   * POST /recipes/suggest — "что мне приготовить?"
   * Возвращает 3 рецепта с пометками нехватки ингредиентов.
   */
  @Post('suggest')
  suggest(
    @Body() dto: SuggestRecipesDto,
    @Headers() headers: Record<string, string>,
  ) {
    const userId = headers['x-user-id'] ?? 'demo-user';
    return this.recipes.suggest(userId, dto);
  }
}
