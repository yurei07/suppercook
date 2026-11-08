import { Unit } from './domain.types';

/**
 * Утилиты работы с единицами измерения.
 *
 * Главное правило: в базе рецептов — только граммы/миллилитры.
 * "Штуки" существуют только на входе (инвентарь пользователя) и
 * конвертируются по средним значениям продукта.
 */

/** Средняя масса одной штуки продукта, г. Заполняется по мере роста справочника. */
const AVERAGE_PIECE_WEIGHT_G: Record<string, number> = {
  'яйцо': 60,
  'лук': 150,
  'лук репчатый': 150,
  'помидор': 120,
  'огурец': 150,
  'картофель': 150,
  'морковь': 80,
  'перец': 150,
  'яблоко': 180,
  'банан': 120,
  'лимон': 100,
  'куриное филе': 200,
  'грудка куриная': 200,
};

/** Средняя масса "единицы" для продуктов, у которых штуки — не совсем штуки */
const FALLBACK_PIECE_WEIGHT_G = 100;

/**
 * Конвертирует количество в граммы (для объёмных — по плотности ≈ 1 г/мл).
 * @param name нормализованное название продукта
 * @param quantity количество
 * @param unit исходная единица
 */
export function toGrams(name: string, quantity: number, unit: Unit): number {
  if (unit === 'g' || unit === 'ml') return quantity;
  const weight = AVERAGE_PIECE_WEIGHT_G[name.toLowerCase()] ?? FALLBACK_PIECE_WEIGHT_G;
  return quantity * weight;
}

/**
 * Конвертирует граммы в целевую единицу (для отображения).
 * Обратная операция toGrams.
 */
export function fromGrams(name: string, grams: number, target: Unit): number {
  if (target === 'g' || target === 'ml') return Math.round(grams);
  const weight = AVERAGE_PIECE_WEIGHT_G[name.toLowerCase()] ?? FALLBACK_PIECE_WEIGHT_G;
  return Math.round((grams / weight) * 10) / 10;
}

/**
 * Нормализует название продукта: нижний регистр, без лишних пробелов.
 * В MVP — базовая нормализация; в v1.1 сюда добавится лемматизация.
 */
export function normalizeIngredientName(raw: string): string {
  return raw.trim().toLowerCase().replace(/\s+/g, ' ');
}
