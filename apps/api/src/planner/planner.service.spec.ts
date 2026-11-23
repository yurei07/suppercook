import { BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  createTestPrisma,
  deleteTestDatabase,
  pushTestSchema,
} from '../testing/test-db';
import { PlannerService } from './planner.service';

/** Тесты синхронизации недельного плана. */
describe('PlannerService', () => {
  let prisma: PrismaService;
  let service: PlannerService;
  const userId = 'plan-user';
  const week = '2026-11-23';

  const recipe = (id: string) => ({
    id,
    title: `Recipe ${id}`,
    minutes: 30,
    servings: 2,
  });

  const upsert = (day: number, slot: string, recipeId: string) =>
    service.upsertMeal(userId, {
      week,
      day,
      slot,
      recipe: recipe(recipeId) as never,
    });

  beforeAll(() => {
    pushTestSchema('test-planner.db');
    prisma = createTestPrisma('test-planner.db') as PrismaService;
    service = new PlannerService(prisma);
  });

  afterAll(async () => {
    await prisma.$disconnect();
    deleteTestDatabase('test-planner.db');
  });

  beforeEach(async () => {
    await prisma.plannedMeal.deleteMany();
  });

  it('начинает с пустого плана', async () => {
    await expect(service.getWeek(userId, week)).resolves.toEqual([]);
  });

  it('upsertMeal ставит блюдо в слот и перезаписывает его', async () => {
    await upsert(0, 'breakfast', 'berry_pancakes');
    await upsert(0, 'breakfast', 'avocado_toast');

    const plan = await service.getWeek(userId, week);
    expect(plan).toHaveLength(1);
    expect(plan[0]).toMatchObject({
      day: 0,
      slot: 'breakfast',
      recipeId: 'avocado_toast',
    });
    expect(plan[0].recipe).toMatchObject({ title: 'Recipe avocado_toast' });
  });

  it('хранит полный снимок рецепта, а не только id', async () => {
    await service.upsertMeal(userId, {
      week,
      day: 2,
      slot: 'dinner',
      recipe: {
        id: 'custom_omelette',
        title: 'Omelette',
        steps: [{ title: 'Whisk', body: 'Whisk the eggs' }],
        ingredients: [{ name: 'Eggs', quantity: 3, unit: 'pcs' }],
      } as never,
    });

    const [meal] = await service.getWeek(userId, week);
    expect(meal.recipe['steps']).toHaveLength(1);
    expect(meal.recipe['ingredients']).toHaveLength(1);
  });

  it('планы разных пользователей не смешиваются', async () => {
    await upsert(1, 'dinner', 'tomato_pasta');
    await service.upsertMeal('other-user', {
      week,
      day: 1,
      slot: 'dinner',
      recipe: recipe('mushroom_pizza') as never,
    });

    const mine = await service.getWeek(userId, week);
    expect(mine).toHaveLength(1);
    expect(mine[0].recipeId).toBe('tomato_pasta');
  });

  it('replaceWeek заменяет всю неделю и не оставляет дублей слотов', async () => {
    await upsert(0, 'breakfast', 'berry_pancakes');
    await service.replaceWeek(userId, {
      week,
      meals: [
        { week, day: 0, slot: 'breakfast', recipe: recipe('a') as never },
        { week, day: 0, slot: 'lunch', recipe: recipe('b') as never },
        { week, day: 1, slot: 'dinner', recipe: recipe('c') as never },
      ],
    });

    const plan = await service.getWeek(userId, week);
    expect(plan).toHaveLength(3);
    expect(plan.find((m) => m.day === 0 && m.slot === 'breakfast')!.recipeId).toBe('a');
  });

  it('replaceWeek отклоняет дубли слота', async () => {
    await expect(
      service.replaceWeek(userId, {
        week,
        meals: [
          { week, day: 0, slot: 'dinner', recipe: recipe('a') as never },
          { week, day: 0, slot: 'dinner', recipe: recipe('b') as never },
        ],
      }),
    ).rejects.toThrow(BadRequestException);
  });

  it('clearMeal освобождает только указанный слот', async () => {
    await upsert(3, 'breakfast', 'berry_pancakes');
    await upsert(3, 'dinner', 'pumpkin_soup');

    await service.clearMeal(userId, week, 3, 'breakfast');

    const plan = await service.getWeek(userId, week);
    expect(plan).toHaveLength(1);
    expect(plan[0].slot).toBe('dinner');
  });

  it('upsertMeal без id/title рецепта отклоняется', async () => {
    await expect(
      service.upsertMeal(userId, {
        week,
        day: 0,
        slot: 'lunch',
        recipe: { title: 'No id' } as never,
      }),
    ).rejects.toThrow(BadRequestException);
  });
});
