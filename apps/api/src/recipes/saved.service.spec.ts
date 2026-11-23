import { BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  createTestPrisma,
  deleteTestDatabase,
  pushTestSchema,
} from '../testing/test-db';
import { SavedRecipesService } from './saved.service';

/** Тесты избранного и истории приготовленного. */
describe('SavedRecipesService', () => {
  let prisma: PrismaService;
  let service: SavedRecipesService;
  const userId = 'saved-user';

  const recipeDto = (id: string) => ({
    recipe: { id, title: `Recipe ${id}`, minutes: 25, servings: 2 },
  });

  beforeAll(() => {
    pushTestSchema('test-saved.db');
    prisma = createTestPrisma('test-saved.db') as PrismaService;
    service = new SavedRecipesService(prisma);
  });

  afterAll(async () => {
    await prisma.$disconnect();
    deleteTestDatabase('test-saved.db');
  });

  beforeEach(async () => {
    await prisma.cookedEntry.deleteMany();
    await prisma.savedRecipe.deleteMany();
  });

  describe('избранное', () => {
    it('сохраняет рецепт со снимком и отдаёт список', async () => {
      await service.save(userId, recipeDto('omelette'));
      const saved = await service.listSaved(userId);
      expect(saved).toHaveLength(1);
      expect(saved[0].recipeId).toBe('omelette');
      expect(saved[0].recipe).toMatchObject({ title: 'Recipe omelette' });
    });

    it('повторное сохранение обновляет снимок, а не дублирует', async () => {
      await service.save(userId, recipeDto('omelette'));
      await service.save(userId, {
        recipe: { id: 'omelette', title: 'Omelette v2' },
      });
      const saved = await service.listSaved(userId);
      expect(saved).toHaveLength(1);
      expect(saved[0].recipe['title']).toBe('Omelette v2');
    });

    it('isSaved различает сохранённое и нет', async () => {
      await service.save(userId, recipeDto('omelette'));
      await expect(service.isSaved(userId, 'omelette')).resolves.toBe(true);
      await expect(service.isSaved(userId, 'pizza')).resolves.toBe(false);
    });

    it('unsave убирает рецепт, повторное — 404', async () => {
      await service.save(userId, recipeDto('omelette'));
      await service.unsave(userId, 'omelette');
      await expect(service.isSaved(userId, 'omelette')).resolves.toBe(false);
      await expect(service.unsave(userId, 'omelette')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('сохранение без id или title отклоняется', async () => {
      await expect(service.save(userId, { recipe: { title: 'no id' } })).rejects.toThrow(
        BadRequestException,
      );
      await expect(service.save(userId, { recipe: { id: 'x' } })).rejects.toThrow(
        BadRequestException,
      );
    });

    it('избранное пользователей изолировано', async () => {
      await service.save(userId, recipeDto('omelette'));
      const other = await service.listSaved('someone-else');
      expect(other).toEqual([]);
    });
  });

  describe('история приготовленного', () => {
    it('записывает приготовления, свежие первыми', async () => {
      await service.markCooked(userId, { recipeId: 'soup', title: 'Soup' });
      await service.markCooked(userId, { recipeId: 'pasta', title: 'Pasta' });

      const history = await service.cookedHistory(userId);
      expect(history).toHaveLength(2);
      expect(history[0].cookedAt.getTime()).toBeGreaterThanOrEqual(
        history[1].cookedAt.getTime(),
      );
      expect(history.map((entry) => entry.recipeId)).toEqual(['pasta', 'soup']);
    });

    it('пустой recipeId отклоняется', async () => {
      await expect(
        service.markCooked(userId, { recipeId: '', title: 'x' }),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
