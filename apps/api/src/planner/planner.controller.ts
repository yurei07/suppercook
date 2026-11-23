import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  Put,
  Query,
} from '@nestjs/common';
import { CurrentUser } from '../auth/current-user.decorator';
import { MEAL_SLOTS, ReplaceWeekDto, UpsertMealDto, WEEK_PATTERN } from './planner.dto';
import { PlannerService } from './planner.service';

@Controller('planner')
export class PlannerController {
  constructor(private readonly planner: PlannerService) {}

  @Get()
  getWeek(
    @CurrentUser() user: { userId: string },
    @Query('week') week?: string,
  ) {
    if (!week || !WEEK_PATTERN.test(week)) {
      throw new BadRequestException(
        'week query param is required (YYYY-MM-DD, a Monday)',
      );
    }
    return this.planner.getWeek(user.userId, week);
  }

  /** Поставить блюдо в слот дня. */
  @Put('meals')
  upsertMeal(
    @Body() dto: UpsertMealDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.planner.upsertMeal(user.userId, dto);
  }

  /** Заменить всю неделю — кнопка «сгенерировать план». */
  @Put()
  replaceWeek(
    @Body() dto: ReplaceWeekDto,
    @CurrentUser() user: { userId: string },
  ) {
    return this.planner.replaceWeek(user.userId, dto);
  }

  @Delete('meals')
  @HttpCode(204)
  async clearMeal(
    @CurrentUser() user: { userId: string },
    @Query('week') week?: string,
    @Query('day') day?: string,
    @Query('slot') slot?: string,
  ): Promise<void> {
    if (!week || !WEEK_PATTERN.test(week)) {
      throw new BadRequestException('week must be YYYY-MM-DD');
    }
    const dayNumber = Number(day);
    if (!Number.isInteger(dayNumber) || dayNumber < 0 || dayNumber > 6) {
      throw new BadRequestException('day must be 0..6');
    }
    if (!slot || !MEAL_SLOTS.includes(slot as (typeof MEAL_SLOTS)[number])) {
      throw new BadRequestException('slot must be breakfast|lunch|dinner');
    }
    await this.planner.clearMeal(user.userId, week, dayNumber, slot);
  }
}
