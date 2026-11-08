import { Injectable, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { InventoryItem } from '../common/domain.types';
import { normalizeIngredientName } from '../common/units';
import { AddInventoryItemDto, UpdateInventoryItemDto } from './inventory.dto';

/**
 * Инвентарь пользователя.
 *
 * MVP: хранение в памяти (Map<userId, InventoryItem[]>).
 * Замена на PostgreSQL + Prisma — отдельная задача v1.1,
 * интерфейс сервиса при этом не меняется.
 */
@Injectable()
export class InventoryService {
  private readonly store = new Map<string, InventoryItem[]>();

  list(userId: string): InventoryItem[] {
    return this.store.get(userId) ?? [];
  }

  add(userId: string, dto: AddInventoryItemDto): InventoryItem[] {
    const items = this.list(userId);
    const name = normalizeIngredientName(dto.name);

    // Если продукт уже есть — суммируем количество, а не создаём дубль
    const existing = items.find(
      (i) => i.name === name && i.unit === dto.unit,
    );

    if (existing) {
      existing.quantity = Math.round((existing.quantity + dto.quantity) * 100) / 100;
    } else {
      items.push({
        id: randomUUID(),
        name,
        quantity: dto.quantity,
        unit: dto.unit,
        addedAt: new Date().toISOString(),
        source: dto.source ?? 'manual',
      });
    }

    this.store.set(userId, items);
    return items;
  }

  update(userId: string, id: string, dto: UpdateInventoryItemDto): InventoryItem {
    const items = this.list(userId);
    const item = items.find((i) => i.id === id);
    if (!item) throw new NotFoundException(`Продукт ${id} не найден`);

    if (dto.name !== undefined) item.name = normalizeIngredientName(dto.name);
    if (dto.quantity !== undefined) item.quantity = dto.quantity;
    if (dto.unit !== undefined) item.unit = dto.unit;

    this.store.set(userId, items);
    return item;
  }

  remove(userId: string, id: string): InventoryItem[] {
    const items = this.list(userId).filter((i) => i.id !== id);
    this.store.set(userId, items);
    return items;
  }

  clear(userId: string): void {
    this.store.delete(userId);
  }
}
