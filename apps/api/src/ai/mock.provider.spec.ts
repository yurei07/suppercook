import { MockAiProvider } from './mock.provider';

describe('MockAiProvider localization', () => {
  const provider = new MockAiProvider();

  it('returns English content when locale is en', async () => {
    const result = await provider.generateRecipes({
      context: {
        userId: 'demo',
        allergens: [],
        preferences: [],
        locale: 'en',
      },
      inventory: [{ name: 'eggs', quantity: 4, unit: 'pcs' }],
    });

    expect(result.recipes.length).toBeGreaterThan(0);
    expect(result.recipes[0].title).toMatch(/Omelette|Eggs/);
    expect(result.recipes[0].ingredients[0].name).toBe('eggs');
  });

  it('returns German content when locale is de', async () => {
    const result = await provider.generateRecipes({
      context: {
        userId: 'demo',
        allergens: [],
        preferences: [],
        locale: 'de',
      },
      inventory: [{ name: 'eier', quantity: 4, unit: 'pcs' }],
    });

    expect(result.recipes.length).toBeGreaterThan(0);
    expect(result.recipes[0].title).toMatch(/Omelett|Spiegeleier/);
    expect(result.recipes[0].ingredients[0].name).toBe('Eier');
  });

  it('localizes recognition results', async () => {
    const en = await provider.recognizeIngredients('', 'image/jpeg', 'en');
    const de = await provider.recognizeIngredients('', 'image/jpeg', 'de');

    expect(en.items[0].name).toBe('eggs');
    expect(de.items[0].name).toBe('Eier');
  });
});
