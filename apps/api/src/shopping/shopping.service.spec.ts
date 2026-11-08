import { ShoppingService } from './shopping.service';
import { InventoryService } from '../inventory/inventory.service';

/**
 * Тесты умного списка покупок — ядро MVP-ценности.
 * Проверяем: diff с инвентарём, дедупликацию, парсинг строк.
 */
describe('ShoppingService', () => {
  let service: ShoppingService;
  let inventory: InventoryService;
  const userId = 'test-user';

  beforeEach(() => {
    inventory = new InventoryService();
    service = new ShoppingService(inventory);
  });

  describe('addFromRecipe — умный diff', () => {
    it('НЕ добавляет продукт, которого достаточно в инвентаре', () => {
      // У пользователя 500 г муки, рецепт требует 300 г
      inventory.add(userId, { name: 'мука', quantity: 500, unit: 'g' });

      service.addFromRecipe(userId, {
        missingIngredients: ['мука (300 g)'],
        recipeId: 'r1',
      });

      expect(service.list(userId)).toHaveLength(0);
    });

    it('добавляет продукт, которого нет в инвентаре', () => {
      service.addFromRecipe(userId, {
        missingIngredients: ['сметана (200 g)'],
        recipeId: 'r1',
      });

      const items = service.list(userId);
      expect(items).toHaveLength(1);
      expect(items[0]).toMatchObject({ name: 'сметана', quantity: 200, unit: 'g' });
    });

    it('добавляет продукт, если количества не хватает', () => {
      inventory.add(userId, { name: 'сыр', quantity: 50, unit: 'g' });

      service.addFromRecipe(userId, {
        missingIngredients: ['сыр (не хватает 150 g)'],
        recipeId: 'r1',
      });

      const items = service.list(userId);
      expect(items).toHaveLength(1);
      expect(items[0].quantity).toBe(150);
    });

    it('парсит формат «сыр (не хватает 80 g)»', () => {
      service.addFromRecipe(userId, {
        missingIngredients: ['сыр (не хватает 80 g)'],
      });

      expect(service.list(userId)[0]).toMatchObject({
        name: 'сыр',
        quantity: 80,
        unit: 'g',
      });
    });
  });

  describe('дедупликация', () => {
    it('объединяет одинаковый ингредиент из двух рецептов', () => {
      service.addFromRecipe(userId, {
        missingIngredients: ['лук (100 g)'],
        recipeId: 'r1',
      });
      service.addFromRecipe(userId, {
        missingIngredients: ['лук (50 g)'],
        recipeId: 'r2',
      });

      const items = service.list(userId);
      expect(items).toHaveLength(1);
      expect(items[0].quantity).toBe(150);
      expect(items[0].recipeIds).toEqual(['r1', 'r2']);
    });

    it('не удваивает количество, если тот же рецепт добавлен дважды', () => {
      service.addFromRecipe(userId, {
        missingIngredients: ['лук (100 g)'],
        recipeId: 'r1',
      });
      service.addFromRecipe(userId, {
        missingIngredients: ['лук (100 g)'],
        recipeId: 'r1',
      });

      expect(service.list(userId)[0].quantity).toBe(100);
    });
  });

  describe('работа со списком', () => {
    it('складывает ручное добавление с существующей позицией', () => {
      service.add(userId, { name: 'Хлеб', quantity: 1, unit: 'g' } as never);
      service.add(userId, { name: 'хлеб', quantity: 2, unit: 'g' });

      const items = service.list(userId);
      expect(items).toHaveLength(1);
      expect(items[0].quantity).toBe(3);
    });

    it('отмечает позицию купленной', () => {
      service.add(userId, { name: 'масло', quantity: 100, unit: 'g' });
      const [item] = service.list(userId);

      const updated = service.toggle(userId, item.id, true);
      expect(updated.checked).toBe(true);
    });

    it('удаляет только купленное через clearChecked', () => {
      service.add(userId, { name: 'масло', quantity: 100, unit: 'g' });
      service.add(userId, { name: 'сахар', quantity: 200, unit: 'g' });
      const [first, second] = service.list(userId);

      service.toggle(userId, first.id, true);
      const rest = service.clearChecked(userId);

      expect(rest).toHaveLength(1);
      expect(rest[0].id).toBe(second.id);
    });
  });
});
