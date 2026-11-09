import { pickRecipeImage } from './recipe-images';

describe('pickRecipeImage', () => {
  it('picks a soup image', () => {
    expect(pickRecipeImage('Creamy Cheese Soup', [], 0)).toBe('pumpkin_soup');
  });

  it('picks a pasta image', () => {
    expect(pickRecipeImage('Fresh Tomato Pasta Sauce', [], 0)).toBe(
      'tomato_pasta',
    );
  });

  it('picks an omelette image', () => {
    expect(pickRecipeImage('Tomato & Cheese Omelette', [], 0)).toBe('omelette');
  });

  it('picks a fried-egg image', () => {
    expect(pickRecipeImage('Fried Eggs with Tomatoes', [], 0)).toBe(
      'fried_eggs',
    );
  });

  it('falls back deterministically', () => {
    expect(pickRecipeImage('Mystery Dish', [], 1)).toBe('salmon_bowl');
  });
});
