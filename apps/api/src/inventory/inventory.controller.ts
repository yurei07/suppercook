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
import { RecognitionResult, Unit } from '../common/domain.types';
import { AiService } from '../ai/ai.service';
import {
  AddInventoryItemDto,
  RecognizePhotoDto,
  UpdateInventoryItemDto,
} from './inventory.dto';
import { InventoryService } from './inventory.service';

/**
 * Инвентарь пользователя — "что у меня в холодильнике".
 * x-user-id: заглушка аутентификации для MVP (см. README, раздел "Известные ограничения").
 */
@Controller('inventory')
export class InventoryController {
  constructor(
    private readonly inventory: InventoryService,
    private readonly ai: AiService,
  ) {}

  @Get()
  list(@Headers() headers: Record<string, string>) {
    return this.inventory.list(this.userId(headers));
  }

  @Post()
  add(
    @Body() dto: AddInventoryItemDto,
    @Headers() headers: Record<string, string>,
  ) {
    return this.inventory.add(this.userId(headers), { ...dto, source: dto.source ?? 'manual' });
  }

  @Patch(':id')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateInventoryItemDto,
    @Headers() headers: Record<string, string>,
  ) {
    return this.inventory.update(this.userId(headers), id, dto);
  }

  @Delete(':id')
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @Headers() headers: Record<string, string>,
  ) {
    return this.inventory.remove(this.userId(headers), id);
  }

  /**
   * Распознавание фото → список предложений.
   * ВАЖНО: клиент обязан показать экран подтверждения —
   * результат не сохраняется автоматически.
   */
  @Post('recognize')
  @HttpCode(200)
  async recognize(@Body() dto: RecognizePhotoDto): Promise<RecognitionResult> {
    const result = await this.ai.recognizeIngredients(
      dto.imageBase64,
      dto.mimeType ?? 'image/jpeg',
      dto.locale ?? 'en',
    );
    return {
      items: result.items.map((i) => ({
        name: i.name,
        quantity: i.quantity,
        unit: i.unit as Unit,
        confidence: i.confidence,
      })),
      summary: result.summary,
    };
  }

  /** Заглушка авторизации: MVP идентифицирует пользователя по заголовку */
  private userId(headers: Record<string, string>): string {
    return headers['x-user-id'] ?? 'demo-user';
  }
}
