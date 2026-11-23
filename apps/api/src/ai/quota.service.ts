import { HttpException, Injectable } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { PrismaService } from '../prisma/prisma.service';

/** Дневной лимит AI-генераций на пользователя (freemium-заготовка). */
const DEFAULT_DAILY_LIMIT = 20;

function todayUtc(): string {
  return new Date().toISOString().slice(0, 10);
}

/**
 * Учитывает AI-вызовы в таблице AiUsage (userId + день UTC).
 * Превышение лимита → 429. Гонка двух параллельных запросов может
 * дать оверсчёт на ±1 — для MVP это приемлемо.
 */
@Injectable()
export class QuotaService {
  private readonly limit = Number(
    process.env.AI_DAILY_LIMIT ?? DEFAULT_DAILY_LIMIT,
  );

  constructor(private readonly prisma: PrismaService) {}

  get dailyLimit(): number {
    return this.limit;
  }

  /** Списывает одну генерацию; бросает 429, если дневной лимит исчерпан. */
  async consume(userId: string): Promise<void> {
    if (!Number.isFinite(this.limit) || this.limit <= 0) {
      throw new HttpException('Daily AI limit reached', 429);
    }

    const day = todayUtc();
    const row = await this.prisma.aiUsage.findUnique({
      where: { userId_day: { userId, day } },
    });

    if (!row) {
      await this.prisma.aiUsage.create({
        data: { id: randomUUID(), userId, day, count: 1 },
      });
      return;
    }

    if (row.count >= this.limit) {
      throw new HttpException('Daily AI limit reached', 429);
    }
    await this.prisma.aiUsage.update({
      where: { id: row.id },
      data: { count: { increment: 1 } },
    });
  }
}
