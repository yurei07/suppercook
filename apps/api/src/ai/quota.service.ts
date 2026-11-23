import { HttpException, Injectable } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { PrismaService } from '../prisma/prisma.service';

/** Дневной лимит AI-генераций на пользователя (freemium-заготовка). */
const DEFAULT_DAILY_LIMIT = 20;

function todayUtc(): string {
  return new Date().toISOString().slice(0, 10);
}

/**
 * Учитывает AI-вызовы в таблице AiUsage (userId + день UTC):
 * количество запросов и суммарные токены (себестоимость).
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

  /** Бросает 429, если дневной лимит исчерпан. Ничего не списывает. */
  async assertWithinLimit(userId: string): Promise<void> {
    if (!Number.isFinite(this.limit) || this.limit <= 0) {
      throw new HttpException('Daily AI limit reached', 429);
    }
    const row = await this.prisma.aiUsage.findUnique({
      where: { userId_day: { userId, day: todayUtc() } },
    });
    if (row && row.count >= this.limit) {
      throw new HttpException('Daily AI limit reached', 429);
    }
  }

  /** Списывает одну генерацию и накопленные токены. */
  async recordUsage(userId: string, tokensUsed: number): Promise<void> {
    const day = todayUtc();
    const tokens = Number.isFinite(tokensUsed) ? Math.max(0, Math.round(tokensUsed)) : 0;

    await this.prisma.aiUsage.upsert({
      where: { userId_day: { userId, day } },
      update: { count: { increment: 1 }, tokens: { increment: tokens } },
      create: {
        id: randomUUID(),
        userId,
        day,
        count: 1,
        tokens,
      },
    });
  }

  /** Совместимо со старым поведением: проверить лимит и списать одну генерацию. */
  async consume(userId: string, tokensUsed = 0): Promise<void> {
    await this.assertWithinLimit(userId);
    await this.recordUsage(userId, tokensUsed);
  }
}
