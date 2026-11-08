import { Injectable } from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { ShoppingListItem, Unit } from '../common/domain.types';
import { normalizeIngredientName, toGrams } from '../common/units';
import { InventoryService } from '../inventory/inventory.service';
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
  private readonly store = new Map<string, ShoppingListItem[]>();

  constructor(private readonly inventory: InventoryService) {}

  list(userId: string): ShoppingListItem[] {
    return this.store.get(userId) ?? [];
  }

  /** Ручное добавление */
  add(userId: string, dto: AddShoppingItemDto): ShoppingListItem[] {
    const items = this.list(userId);
    const name = normalizeIngredientName(dto.name);

    const existing = items.find((i) => i.name === name && i.unit === dto.unit);
    if (existing) {
      existing.quantity = Math.round((existing.quantity + dto.quantity) * 100) / 100;
    } else {
      items.push({
        id: randomUUID(),
        name,
        quantity: dto.quantity,
        unit: dto.unit,
        recipeIds: [],
        checked: false,
      });
    }

    this.store.set(userId, items);
    return items;
  }

  /**
   * Добавление недостающего из рецепта.
   * Строки вида "сыр (150 g)" / "сыр (не хватает 80 g)" парсим здесь.
   */
  addFromRecipe(userId: string, dto: AddFromRecipeDto): ShoppingListItem[] {
    const items = this.list(userId);

    for (const raw of dto.missingIngredients) {
      const parsed = this.parseMissing(raw);
      if (!parsed) continue;

      // ===== ГЛАВНОЕ ПРАВИЛО УМНОГО СПИСКА =====
      // Если в инвентаре уже есть нужное количество — не добавляем.
      if (this.hasEnoughInInventory(userId, parsed.name, parsed.quantity, parsed.unit)) {
        continue;
      }

      const recipeId = dto.recipeId;
      const existing = items.find(
        (i) => i.name === parsed.name && i.unit === parsed.unit,
      );

      if (existing) {
        // Дедупликация: добавляем количество только если этот рецепт ещё не учитывался
        if (recipeId && existing.recipeIds.includes(recipeId)) continue;
        if (recipeId) existing.recipeIds.push(recipeId);
        existing.quantity =
          Math.round((existing.quantity + parsed.quantity) * 100) / 100;
      } else {
        items.push({
          id: randomUUID(),
          name: parsed.name,
          quantity: parsed.quantity,
          unit: parsed.unit,
          recipeIds: recipeId ? [recipeId] : [],
          checked: false,
        });
      }
    }

    this.store.set(userId, items);
    return items;
  }

  toggle(userId: string, id: string, checked: boolean): ShoppingListItem {
    const items = this.list(userId);
    const item = items.find((i) => i.id === id);
    if (item) {
      item.checked = checked;
      this.store.set(userId, items);
    }
    return item as ShoppingListItem;
  }

  remove(userId: string, id: string): ShoppingListItem[] {
    const items = this.list(userId).filter((i) => i.id !== id);
    this.store.set(userId, items);
    return items;
  }

  /** Убрать всё купленное */
  clearChecked(userId: string): ShoppingListItem[] {
    const items = this.list(userId).filter((i) => !i.checked);
    this.store.set(userId, items);
    return items;
  }

  /**
   * Проверка: есть ли в инвентаре достаточно продукта.
   * Работаем в граммах — "200 г" vs "1 шт" конвертируется по средней массе.
   */
  private hasEnoughInInventory(
    userId: string,
    name: string,
    quantity: number,
    unit: Unit,
  ): boolean {
    const item = this.inventory.list(userId).find((i) => i.name === name);
    if (!item) return false;

    const have = toGrams(item.name, item.quantity, item.unit);
    const need = toGrams(name, quantity, unit);
    return have >= need;
  }

  /** Разбирает строку вида "сыр (не хватает 80 g)" или "сыр (150 g)" */
  private parseMissing(
    raw: string,
  ): { name: string; quantity: number; unit: 'g' | 'ml' } | null {
    const match = raw.match(/^(.+?)\s*\((?:не хватает\s*)?([\d.,]+)\s*(g|ml)\)$/i);
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
