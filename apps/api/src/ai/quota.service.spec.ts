import { HttpException } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { PrismaService } from '../prisma/prisma.service';
import {
  createTestPrisma,
  deleteTestDatabase,
  pushTestSchema,
} from '../testing/test-db';
import { QuotaService } from './quota.service';

/** Тесты дневного лимита AI-генераций (защита от разорения на токенах). */
describe('QuotaService', () => {
  let prisma: PrismaService;
  let service: QuotaService;

  beforeAll(() => {
    pushTestSchema('test-quota.db');
    prisma = createTestPrisma('test-quota.db') as PrismaService;
    service = new QuotaService(prisma);
  });

  afterAll(async () => {
    await prisma.$disconnect();
    deleteTestDatabase('test-quota.db');
  });

  beforeEach(async () => {
    await prisma.aiUsage.deleteMany();
  });

  it('пропускает запросы в пределах дневного лимита', async () => {
    const userId = randomUUID();
    const limit = service.dailyLimit;
    expect(limit).toBeGreaterThan(0);

    for (let i = 0; i < limit; i++) {
      await expect(service.consume(userId)).resolves.toBeUndefined();
    }
    const row = await prisma.aiUsage.findFirst({ where: { userId } });
    expect(row!.count).toBe(limit);
  });

  it('recordUsage копит токены поверх счётчика генераций', async () => {
    const userId = randomUUID();
    await service.recordUsage(userId, 1200);
    await service.recordUsage(userId, 800);

    const row = await prisma.aiUsage.findFirst({ where: { userId } });
    expect(row!.count).toBe(2);
    expect(row!.tokens).toBe(2000);
  });

  it('assertWithinLimit не списывает генерацию сам по себе', async () => {
    const userId = randomUUID();
    for (let i = 0; i < service.dailyLimit; i++) await service.consume(userId);

    // Лимит исчерпан — проверить можно, но списать нельзя
    await expect(service.assertWithinLimit(userId)).rejects.toThrow('limit');
    const row = await prisma.aiUsage.findFirst({ where: { userId } });
    expect(row!.count).toBe(service.dailyLimit);
  });

  it('бросает 429 после исчерпания дневного лимита', async () => {
    const userId = randomUUID();
    const limit = service.dailyLimit;
    for (let i = 0; i < limit; i++) await service.consume(userId);

    const err = await service.consume(userId).catch((e) => e);
    expect(err).toBeInstanceOf(HttpException);
    expect(err.getStatus()).toBe(429);
  });

  it('считает лимит отдельно на каждого пользователя', async () => {
    const exhausted = randomUUID();
    const fresh = randomUUID();
    for (let i = 0; i < service.dailyLimit; i++) await service.consume(exhausted);

    await expect(service.consume(exhausted)).rejects.toThrow('limit');
    await expect(service.consume(fresh)).resolves.toBeUndefined();
  });

  it('ведёт отдельный счётчик на каждый день UTC', async () => {
    const userId = randomUUID();
    const day = new Date().toISOString().slice(0, 10);
    for (let i = 0; i < service.dailyLimit; i++) await service.consume(userId);

    await expect(service.consume(userId)).rejects.toThrow();

    // Симулируем «завтра»: сдвигаем день в записи
    await prisma.aiUsage.updateMany({
      where: { userId },
      data: { day: '2000-01-01' },
    });
    // Сегодняшней записи больше нет — квота снова доступна
    await expect(service.consume(userId)).resolves.toBeUndefined();

    const rows = await prisma.aiUsage.findMany({ where: { userId } });
    expect(rows).toHaveLength(2);
    expect(rows.find((r) => r.day === '2000-01-01')!.count).toBe(day ? service.dailyLimit : 0);
  });
});
