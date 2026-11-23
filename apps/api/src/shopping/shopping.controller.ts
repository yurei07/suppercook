import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
} from '@nestjs/common';
import { CurrentUser } from '../auth/current-user.decorator';
import {
  AddFromRecipeDto,
  AddShoppingItemDto,
  ToggleShoppingItemDto,
} from './shopping.dto';
import { ShoppingService } from './shopping.service';

@Controller('shopping')
export class ShoppingController {
  constructor(private readonly shopping: ShoppingService) {}

  @Get()
  list(@CurrentUser() user: { userId: string }) {
    return this.shopping.list(user.userId);
  }

  @Post('items')
  add(
    @Body() dto: AddShoppingItemDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.shopping.add(user.userId, dto);
  }

  /** Кнопка «Добавить недостающее в список покупок» на экране рецепта */
  @Post('from-recipe')
  addFromRecipe(
    @Body() dto: AddFromRecipeDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.shopping.addFromRecipe(user.userId, dto);
  }

  @Patch('items/:id')
  toggle(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ToggleShoppingItemDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.shopping.toggle(user.userId, id, dto.checked);
  }

  @Delete('items/:id')
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: { userId: string },
  ) {
    return this.shopping.remove(user.userId, id);
  }

  @Delete('checked')
  @HttpCode(204)
  clearChecked(@CurrentUser() user: { userId: string }): void {
    this.shopping.clearChecked(user.userId);
  }
}
