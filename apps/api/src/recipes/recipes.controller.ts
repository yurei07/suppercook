import { Body, Controller, Post } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { QuotaService } from '../ai/quota.service';
import { CurrentUser } from '../auth/current-user.decorator';
import { SuggestRecipesDto } from './recipes.dto';
import { RecipesService } from './recipes.service';

// Генерация рецептов — дорогой AI-вызов.
const AI_THROTTLE = { default: { limit: 10, ttl: 60_000 } };

@Controller('recipes')
export class RecipesController {
  constructor(
    private readonly recipes: RecipesService,
    private readonly quota: QuotaService,
  ) {}

  /**
   * POST /recipes/suggest — "что мне приготовить?"
   * Возвращает 3 рецепта с пометками нехватки ингредиентов.
   */
  @Post('suggest')
  @Throttle(AI_THROTTLE)
  async suggest(
    @Body() dto: SuggestRecipesDto,
    @CurrentUser() user: { userId: string },
  ) {
    // Лимит проверяем ДО вызова, токены списываем после факта
    await this.quota.assertWithinLimit(user.userId);
    const { recipes, tokensUsed } = await this.recipes.suggest(user.userId, dto);
    await this.quota.recordUsage(user.userId, tokensUsed);
    return recipes;
  }
}
