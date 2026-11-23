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
import { Throttle } from '@nestjs/throttler';
import { RecognitionResult, Unit } from '../common/domain.types';
import { AiService } from '../ai/ai.service';
import { QuotaService } from '../ai/quota.service';
import { CurrentUser } from '../auth/current-user.decorator';
import {
  AddInventoryItemDto,
  RecognizePhotoDto,
  UpdateInventoryItemDto,
} from './inventory.dto';
import { InventoryService } from './inventory.service';

// Распознавание фото — самый дорогой вызов, лимит строже глобального.
const AI_THROTTLE = { default: { limit: 10, ttl: 60_000 } };

@Controller('inventory')
export class InventoryController {
  constructor(
    private readonly inventory: InventoryService,
    private readonly ai: AiService,
    private readonly quota: QuotaService,
  ) {}

  @Get()
  list(@CurrentUser() user: { userId: string }) {
    return this.inventory.list(user.userId);
  }

  @Post()
  add(@Body() dto: AddInventoryItemDto, @CurrentUser() user: { userId: string }) {
    return this.inventory.add(user.userId, { ...dto, source: dto.source ?? 'manual' });
  }

  @Patch(':id')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateInventoryItemDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.inventory.update(user.userId, id, dto);
  }

  @Delete(':id')
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: { userId: string },
  ) {
    return this.inventory.remove(user.userId, id);
  }

  /**
   * Распознавание фото → список предложений.
   * ВАЖНО: клиент обязан показать экран подтверждения —
   * результат не сохраняется автоматически.
   */
  @Post('recognize')
  @HttpCode(200)
  @Throttle(AI_THROTTLE)
  async recognize(
    @Body() dto: RecognizePhotoDto,
    @CurrentUser() user: { userId: string },
  ): Promise<RecognitionResult> {
    await this.quota.consume(user.userId);
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
}
