import { InventoryService } from '../inventory/inventory.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  createTestPrisma,
  deleteTestDatabase,
  pushTestSchema,
} from '../testing/test-db';
import { ShoppingService } from './shopping.service';

/**
 * Тесты умного списка покупок — ядро MVP-ценности.
 * Проверяем: diff с инвентарём, дедупликацию, парсинг строк.
 */
describe('ShoppingService', () => {
  let prisma: PrismaService;
  let service: ShoppingService;
  let inventory: InventoryService;
  const userId = 'test-user';

  beforeAll(() => {
    pushTestSchema('test-shopping.db');
    prisma = createTestPrisma('test-shopping.db') as PrismaService;
    inventory = new InventoryService(prisma);
    service = new ShoppingService(inventory, prisma);
  });

  afterAll(async () => {
    await prisma.$disconnect();
    deleteTestDatabase('test-shopping.db');
  });

  beforeEach(async () => {
    await prisma.shoppingItem.deleteMany();
    await prisma.inventoryItem.deleteMany();
  });

  describe('addFromRecipe — умный diff', () => {
    it('НЕ добавляет продукт, которого достаточно в инвентаре', async () => {
      // У пользователя 500 г муки, рецепт требует 300 г
      await inventory.add(userId, { name: 'мука', quantity: 500, unit: 'g' });

      await service.addFromRecipe(userId, {
        missingIngredients: ['мука (300 g)'],
        recipeId: 'r1',
      });

      expect(await service.list(userId)).toHaveLength(0);
    });

    it('добавляет продукт, которого нет в инвентаре', async () => {
      await service.addFromRecipe(userId, {
        missingIngredients: ['сметана (200 g)'],
        recipeId: 'r1',
      });

      const items = await service.list(userId);
      expect(items).toHaveLength(1);
      expect(items[0]).toMatchObject({
        name: 'сметана',
        quantity: 200,
        unit: 'g',
      });
    });

    it('добавляет продукт, если количества не хватает', async () => {
      await inventory.add(userId, { name: 'сыр', quantity: 50, unit: 'g' });

      await service.addFromRecipe(userId, {
        missingIngredients: ['сыр (не хватает 150 g)'],
        recipeId: 'r1',
      });

      const items = await service.list(userId);
      expect(items).toHaveLength(1);
      expect(items[0].quantity).toBe(150);
    });

    it('парсит формат «сыр (не хватает 80 g)»', async () => {
      await service.addFromRecipe(userId, {
        missingIngredients: ['сыр (не хватает 80 g)'],
      });

      expect((await service.list(userId))[0]).toMatchObject({
        name: 'сыр',
        quantity: 80,
        unit: 'g',
      });
    });
  });

  describe('дедупликация', () => {
    it('объединяет одинаковый ингредиент из двух рецептов', async () => {
      await service.addFromRecipe(userId, {
        missingIngredients: ['лук (100 g)'],
        recipeId: 'r1',
      });
      await service.addFromRecipe(userId, {
        missingIngredients: ['лук (50 g)'],
        recipeId: 'r2',
      });

      const items = await service.list(userId);
      expect(items).toHaveLength(1);
      expect(items[0].quantity).toBe(150);
      expect(items[0].recipeIds).toEqual(['r1', 'r2']);
    });

    it('не удваивает количество, если тот же рецепт добавлен дважды', async () => {
      await service.addFromRecipe(userId, {
        missingIngredients: ['лук (100 g)'],
        recipeId: 'r1',
      });
      await service.addFromRecipe(userId, {
        missingIngredients: ['лук (100 g)'],
        recipeId: 'r1',
      });

      expect((await service.list(userId))[0].quantity).toBe(100);
    });
  });

  describe('работа со списком', () => {
    it('складывает ручное добавление с существующей позицией', async () => {
      await service.add(userId, { name: 'Хлеб', quantity: 1, unit: 'g' });
      await service.add(userId, { name: 'хлеб', quantity: 2, unit: 'g' });

      const items = await service.list(userId);
      expect(items).toHaveLength(1);
      expect(items[0].quantity).toBe(3);
    });

    it('отмечает позицию купленной', async () => {
      await service.add(userId, { name: 'масло', quantity: 100, unit: 'g' });
      const [item] = await service.list(userId);

      const updated = await service.toggle(userId, item.id, true);
      expect(updated.checked).toBe(true);
    });

    it('удаляет только купленное через clearChecked', async () => {
      await service.add(userId, { name: 'масло', quantity: 100, unit: 'g' });
      await service.add(userId, { name: 'сахар', quantity: 200, unit: 'g' });
      const [first, second] = await service.list(userId);

      await service.toggle(userId, first.id, true);
      const rest = await service.clearChecked(userId);

      expect(rest).toHaveLength(1);
      expect(rest[0].id).toBe(second.id);
    });
  });
});
