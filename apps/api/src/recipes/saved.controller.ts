import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  Post,
  Put,
} from '@nestjs/common';
import { CurrentUser } from '../auth/current-user.decorator';
import { CookedDto, SaveRecipeDto } from './saved.dto';
import { SavedRecipesService } from './saved.service';

@Controller('recipes')
export class SavedRecipesController {
  constructor(private readonly saved: SavedRecipesService) {}

  @Get('saved')
  listSaved(@CurrentUser() user: { userId: string }) {
    return this.saved.listSaved(user.userId);
  }

  /** Сохранить рецепт (избранное). Снимок хранится целиком. */
  @Put('saved/:recipeId')
  async save(
    @Param('recipeId') recipeId: string,
    @Body() dto: SaveRecipeDto,
    @CurrentUser() user: { userId: string },
  ): Promise<void> {
    await this.saved.save(user.userId, { recipe: { ...dto.recipe, id: recipeId } });
  }

  @Delete('saved/:recipeId')
  @HttpCode(204)
  async unsave(
    @Param('recipeId') recipeId: string,
    @CurrentUser() user: { userId: string },
  ): Promise<void> {
    await this.saved.unsave(user.userId, recipeId);
  }

  @Get('cooked')
  cookedHistory(@CurrentUser() user: { userId: string }) {
    return this.saved.cookedHistory(user.userId);
  }

  /** Записать приготовление в историю. */
  @Post('cooked')
  @HttpCode(201)
  async markCooked(
    @Body() dto: CookedDto,
    @CurrentUser() user: { userId: string },
  ): Promise<void> {
    await this.saved.markCooked(user.userId, dto);
  }
}
