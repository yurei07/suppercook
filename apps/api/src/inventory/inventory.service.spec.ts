import { InventoryService } from './inventory.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  createTestPrisma,
  deleteTestDatabase,
  pushTestSchema,
} from '../testing/test-db';

describe('InventoryService', () => {
  let prisma: PrismaService;
  let service: InventoryService;
  const userId = 'test-user';

  beforeAll(() => {
    pushTestSchema('test-inventory.db');
    prisma = createTestPrisma('test-inventory.db') as PrismaService;
    service = new InventoryService(prisma);
  });

  afterAll(async () => {
    await prisma.$disconnect();
    deleteTestDatabase('test-inventory.db');
  });

  beforeEach(async () => {
    await prisma.inventoryItem.deleteMany();
  });

  it('начинает с пустого инвентаря', async () => {
    await expect(service.list(userId)).resolves.toEqual([]);
  });

  it('добавляет продукт и отдаёт его в списке', async () => {
    await service.add(userId, { name: 'яйцо', quantity: 6, unit: 'pcs' });
    const items = await service.list(userId);

    expect(items).toHaveLength(1);
    expect(items[0]).toMatchObject({ name: 'яйцо', quantity: 6, unit: 'pcs' });
  });

  it('суммирует количество при повторном добавлении того же продукта', async () => {
    await service.add(userId, { name: 'Молоко', quantity: 500, unit: 'ml' });
    await service.add(userId, { name: 'молоко', quantity: 200, unit: 'ml' });

    const items = await service.list(userId);
    expect(items).toHaveLength(1);
    expect(items[0].quantity).toBe(700);
  });

  it('не смешивает одинаковое название с разными единицами', async () => {
    await service.add(userId, { name: 'сыр', quantity: 200, unit: 'g' });
    await service.add(userId, { name: 'сыр', quantity: 1, unit: 'pcs' });

    expect(await service.list(userId)).toHaveLength(2);
  });

  it('обновляет название и количество', async () => {
    await service.add(userId, { name: 'лук', quantity: 2, unit: 'pcs' });
    const [item] = await service.list(userId);

    const updated = await service.update(userId, item.id, {
      name: 'лук репчатый',
      quantity: 3,
    });

    expect(updated).toMatchObject({ name: 'лук репчатый', quantity: 3 });
  });

  it('бросает 404 при обновлении чужого или несуществующего продукта', async () => {
    await service.add(userId, { name: 'морковь', quantity: 2, unit: 'pcs' });
    const [item] = await service.list(userId);

    await expect(
      service.update('other-user', item.id, { quantity: 5 }),
    ).rejects.toThrow('не найден');
  });

  it('удаляет продукт', async () => {
    await service.add(userId, { name: 'масло', quantity: 100, unit: 'g' });
    const [item] = await service.list(userId);

    const rest = await service.remove(userId, item.id);
    expect(rest).toHaveLength(0);
  });
});
