import { Injectable, NotFoundException } from '@nestjs/common';
import { ShoppingItem as ShoppingItemRow } from '@prisma/client';
import { randomUUID } from 'node:crypto';
import { ShoppingListItem, Unit } from '../common/domain.types';
import { normalizeIngredientName, toGrams } from '../common/units';
import { InventoryService } from '../inventory/inventory.service';
import { PrismaService } from '../prisma/prisma.service';
import { AddFromRecipeDto, AddShoppingItemDto } from './shopping.dto';

/**
 * Умный список покупок.
 *
 * Ключевая логика (MVP-ценность):
 * 1. При добавлении из рецепта позиция берётся ТОЛЬКО если её не хватает
 *    в инвентаре (diff уже посчитан в RecipesService).
 * 2. Дедупликация: один и тот же ингредиент из разных рецептов объединяется,
 *    количество суммируется, recipeIds — склеиваются.
 * 3. Позиции с разными единицами не смешиваются.
 */
@Injectable()
export class ShoppingService {
  constructor(
    private readonly inventory: InventoryService,
    private readonly prisma: PrismaService,
  ) {}

  async list(userId: string): Promise<ShoppingListItem[]> {
    const rows = await this.prisma.shoppingItem.findMany({
      where: { userId },
      orderBy: { name: 'asc' },
    });
    return rows.map(toDomain);
  }

  /** Ручное добавление */
  async add(
    userId: string,
    dto: AddShoppingItemDto,
  ): Promise<ShoppingListItem[]> {
    const name = normalizeIngredientName(dto.name);

    const existing = await this.prisma.shoppingItem.findFirst({
      where: { userId, name, unit: dto.unit },
    });
    if (existing) {
      await this.prisma.shoppingItem.update({
        where: { id: existing.id },
        data: {
          quantity: Math.round((existing.quantity + dto.quantity) * 100) / 100,
        },
      });
    } else {
      await this.prisma.shoppingItem.create({
        data: {
          id: randomUUID(),
          userId,
          name,
          quantity: dto.quantity,
          unit: dto.unit,
          recipeIds: '[]',
        },
      });
    }

    return this.list(userId);
  }

  /**
   * Добавление недостающего из рецепта.
   * Строки вида "сыр (150 g)" / "сыр (не хватает 80 g)" парсим здесь.
   */
  async addFromRecipe(
    userId: string,
    dto: AddFromRecipeDto,
  ): Promise<ShoppingListItem[]> {
    for (const raw of dto.missingIngredients) {
      const parsed = this.parseMissing(raw);
      if (!parsed) continue;

      // ===== ГЛАВНОЕ ПРАВИЛО УМНОГО СПИСКА =====
      // Если в инвентаре уже есть нужное количество — не добавляем.
      const hasEnough = await this.hasEnoughInInventory(
        userId,
        parsed.name,
        parsed.quantity,
        parsed.unit,
      );
      if (hasEnough) continue;

      const recipeId = dto.recipeId;
      const existing = await this.prisma.shoppingItem.findFirst({
        where: { userId, name: parsed.name, unit: parsed.unit },
      });

      if (existing) {
        const recipeIds = parseRecipeIds(existing.recipeIds);
        if (recipeId && recipeIds.includes(recipeId)) continue;

        await this.prisma.shoppingItem.update({
          where: { id: existing.id },
          data: {
            quantity:
              Math.round((existing.quantity + parsed.quantity) * 100) / 100,
            recipeIds: JSON.stringify(
              recipeId ? [...recipeIds, recipeId] : recipeIds,
            ),
          },
        });
      } else {
        await this.prisma.shoppingItem.create({
          data: {
            id: randomUUID(),
            userId,
            name: parsed.name,
            quantity: parsed.quantity,
            unit: parsed.unit,
            recipeIds: recipeId ? JSON.stringify([recipeId]) : '[]',
          },
        });
      }
    }

    return this.list(userId);
  }

  async toggle(
    userId: string,
    id: string,
    checked: boolean,
  ): Promise<ShoppingListItem> {
    const item = await this.prisma.shoppingItem.findFirst({
      where: { id, userId },
    });
    if (!item) throw new NotFoundException(`Позиция ${id} не найдена`);

    const updated = await this.prisma.shoppingItem.update({
      where: { id },
      data: { checked },
    });
    return toDomain(updated);
  }

  async remove(userId: string, id: string): Promise<ShoppingListItem[]> {
    await this.prisma.shoppingItem.deleteMany({ where: { id, userId } });
    return this.list(userId);
  }

  /** Убрать всё купленное */
  async clearChecked(userId: string): Promise<ShoppingListItem[]> {
    await this.prisma.shoppingItem.deleteMany({
      where: { userId, checked: true },
    });
    return this.list(userId);
  }

  /**
   * Проверка: есть ли в инвентаре достаточно продукта.
   * Работаем в граммах — "200 г" vs "1 шт" конвертируется по средней массе.
   */
  private async hasEnoughInInventory(
    userId: string,
    name: string,
    quantity: number,
    unit: Unit,
  ): Promise<boolean> {
    const pantry = await this.inventory.list(userId);
    const item = pantry.find((entry) => entry.name === name);
    if (!item) return false;

    const have = toGrams(item.name, item.quantity, item.unit);
    const need = toGrams(name, quantity, unit);
    return have >= need;
  }

  /** Разбирает строку вида "сыр (не хватает 80 g)" или "сыр (150 g)" */
  private parseMissing(
    raw: string,
  ): { name: string; quantity: number; unit: 'g' | 'ml' } | null {
    const match = raw.match(
      /^(.+?)\s*\((?:не хватает\s*)?([\d.,]+)\s*(g|ml)\)$/i,
    );
    if (match) {
      return {
        name: normalizeIngredientName(match[1]),
        quantity: parseFloat(match[2].replace(',', '.')),
        unit: match[3].toLowerCase() as 'g' | 'ml',
      };
    }
    // Не удалось распарсить — берём название без количества, 100 г по умолчанию
    const nameOnly = raw.replace(/\s*\(.*\)\s*/, '').trim();
    if (!nameOnly) return null;
    return { name: normalizeIngredientName(nameOnly), quantity: 100, unit: 'g' };
  }
}

function parseRecipeIds(raw: string): string[] {
  try {
    const parsed = JSON.parse(raw);
    if (Array.isArray(parsed)) {
      return parsed.filter((value) => typeof value === 'string');
    }
  } catch {
    // повреждённая запись — считаем, что рецептов нет
  }
  return [];
}

function toDomain(row: ShoppingItemRow): ShoppingListItem {
  return {
    id: row.id,
    name: row.name,
    quantity: row.quantity,
    unit: row.unit as Exclude<Unit, 'pcs'>,
    recipeIds: parseRecipeIds(row.recipeIds),
    checked: row.checked,
  };
}
