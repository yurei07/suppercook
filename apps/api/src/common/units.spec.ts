import { fromGrams, normalizeIngredientName, toGrams } from './units';

/**
 * Тесты конвертации единиц — критично для корректности
 * списка покупок и будущего КБЖУ-планирования.
 */
describe('units', () => {
  describe('normalizeIngredientName', () => {
    it('приводит к нижнему регистру и убирает лишние пробелы', () => {
      expect(normalizeIngredientName('  Молоко   Коровье ')).toBe('молоко коровье');
    });
  });

  describe('toGrams', () => {
    it('граммы проходят без изменений', () => {
      expect(toGrams('сыр', 200, 'g')).toBe(200);
    });

    it('миллилитры ≈ граммы (плотность ≈ 1)', () => {
      expect(toGrams('молоко', 500, 'ml')).toBe(500);
    });

    it('конвертирует штуки по средней массе продукта', () => {
      // яйцо ≈ 60 г
      expect(toGrams('яйцо', 4, 'pcs')).toBe(240);
      // лук ≈ 150 г
      expect(toGrams('лук', 2, 'pcs')).toBe(300);
    });

    it('использует значение по умолчанию для неизвестного продукта', () => {
      expect(toGrams('загадочный продукт', 2, 'pcs')).toBe(200);
    });
  });

  describe('fromGrams', () => {
    it('обратная конвертация для известного продукта', () => {
      // 240 г яиц = 4 шт
      expect(fromGrams('яйцо', 240, 'pcs')).toBe(4);
    });

    it('граммы округляются до целого', () => {
      expect(fromGrams('сыр', 150.6, 'g')).toBe(151);
    });
  });

  describe('toGrams ↔ fromGrams', () => {
    it('конвертация туда-обратно не теряет смысл', () => {
      const grams = toGrams('помидор', 3, 'pcs'); // 360
      expect(fromGrams('помидор', grams, 'pcs')).toBe(3);
    });
  });
});
