/**
 * Детерминированный выбор ключа изображения для сгенерированного рецепта.
 * Клиент маппит ключ на локальный ассет (assets/images/food/<key>.jpg).
 * Позже ключи можно заменить на URL из CDN.
 */
const FALLBACK_IMAGES = [
  'shared_table',
  'salmon_bowl',
  'tomato_pasta',
  'green_salad',
  'pumpkin_soup',
  'mushroom_pizza',
  'berry_pancakes',
  'avocado_toast',
  'harvest_bowl',
  'caesar_salad',
];

export function pickRecipeImage(
  title: string,
  tags: string[],
  index: number,
): string {
  const haystack = `${title} ${tags.join(' ')}`.toLowerCase();

  if (/(soup|suppe|суп)/.test(haystack)) return 'pumpkin_soup';
  if (/(pasta|nudel|sauce|соус)/.test(haystack)) return 'tomato_pasta';
  if (/(pizza|пицца)/.test(haystack)) return 'mushroom_pizza';
  if (/(salad|salat|салат)/.test(haystack)) return 'green_salad';
  if (/(salmon|lachs|fisch|fish|лосось|рыба)/.test(haystack)) {
    return 'salmon_bowl';
  }
  if (/(pancake|pfannkuchen|блин)/.test(haystack)) return 'berry_pancakes';
  if (/(omelette|omelett|омлет)/.test(haystack)) return 'omelette';
  if (/(fried eggs|spiegelei|яичниц)/.test(haystack)) return 'fried_eggs';
  if (/(egg|ei|завтрак|breakfast|frühstück)/.test(haystack)) {
    return 'avocado_toast';
  }
  if (/(bowl|боул)/.test(haystack)) return 'harvest_bowl';

  return FALLBACK_IMAGES[index % FALLBACK_IMAGES.length];
}
