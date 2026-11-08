import {
  Body,
  Controller,
  Delete,
  Get,
  Headers,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
} from '@nestjs/common';
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
  list(@Headers() headers: Record<string, string>) {
    return this.shopping.list(this.userId(headers));
  }

  @Post('items')
  add(@Body() dto: AddShoppingItemDto, @Headers() headers: Record<string, string>) {
    return this.shopping.add(this.userId(headers), dto);
  }

  /** Кнопка «Добавить недостающее в список покупок» на экране рецепта */
  @Post('from-recipe')
  addFromRecipe(@Body() dto: AddFromRecipeDto, @Headers() headers: Record<string, string>) {
    return this.shopping.addFromRecipe(this.userId(headers), dto);
  }

  @Patch('items/:id')
  toggle(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ToggleShoppingItemDto,
    @Headers() headers: Record<string, string>,
  ) {
    return this.shopping.toggle(this.userId(headers), id, dto.checked);
  }

  @Delete('items/:id')
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @Headers() headers: Record<string, string>,
  ) {
    return this.shopping.remove(this.userId(headers), id);
  }

  @Delete('checked')
  @HttpCode(204)
  clearChecked(@Headers() headers: Record<string, string>): void {
    this.shopping.clearChecked(this.userId(headers));
  }

  private userId(headers: Record<string, string>): string {
    return headers['x-user-id'] ?? 'demo-user';
  }
}
