import { Injectable, NotFoundException } from '@nestjs/common';
import {
  InventoryItem as InventoryItemRow,
  Prisma,
} from '@prisma/client';
import { randomUUID } from 'node:crypto';
import { InventoryItem, Unit } from '../common/domain.types';
import { normalizeIngredientName } from '../common/units';
import { PrismaService } from '../prisma/prisma.service';
import { AddInventoryItemDto, UpdateInventoryItemDto } from './inventory.dto';

/**
 * Инвентарь пользователя. Хранится в базе (SQLite локально, PostgreSQL в проде).
 * Дубль продукта не создаётся: при совпадении name+unit количество суммируется.
 */
@Injectable()
export class InventoryService {
  constructor(private readonly prisma: PrismaService) {}

  async list(userId: string): Promise<InventoryItem[]> {
    const rows = await this.prisma.inventoryItem.findMany({
      where: { userId },
      orderBy: { addedAt: 'asc' },
    });
    return rows.map(toDomain);
  }

  async add(userId: string, dto: AddInventoryItemDto): Promise<InventoryItem[]> {
    const name = normalizeIngredientName(dto.name);

    const existing = await this.prisma.inventoryItem.findFirst({
      where: { userId, name, unit: dto.unit },
    });

    if (existing) {
      await this.prisma.inventoryItem.update({
        where: { id: existing.id },
        data: {
          quantity:
            Math.round((existing.quantity + dto.quantity) * 100) / 100,
        },
      });
    } else {
      await this.prisma.inventoryItem.create({
        data: {
          id: randomUUID(),
          userId,
          name,
          quantity: dto.quantity,
          unit: dto.unit,
          source: dto.source ?? 'manual',
        },
      });
    }

    return this.list(userId);
  }

  async update(
    userId: string,
    id: string,
    dto: UpdateInventoryItemDto,
  ): Promise<InventoryItem> {
    const item = await this.prisma.inventoryItem.findFirst({
      where: { id, userId },
    });
    if (!item) throw new NotFoundException(`Продукт ${id} не найден`);

    const data: Prisma.InventoryItemUpdateInput = {};
    if (dto.name !== undefined) data.name = normalizeIngredientName(dto.name);
    if (dto.quantity !== undefined) data.quantity = dto.quantity;
    if (dto.unit !== undefined) data.unit = dto.unit;

    const updated = await this.prisma.inventoryItem.update({
      where: { id },
      data,
    });
    return toDomain(updated);
  }

  async remove(userId: string, id: string): Promise<InventoryItem[]> {
    await this.prisma.inventoryItem.deleteMany({ where: { id, userId } });
    return this.list(userId);
  }

  async clear(userId: string): Promise<void> {
    await this.prisma.inventoryItem.deleteMany({ where: { userId } });
  }
}

function toDomain(row: InventoryItemRow): InventoryItem {
  return {
    id: row.id,
    name: row.name,
    quantity: row.quantity,
    unit: row.unit as Unit,
    addedAt: row.addedAt.toISOString(),
    source: row.source === 'photo' ? 'photo' : 'manual',
  };
}
