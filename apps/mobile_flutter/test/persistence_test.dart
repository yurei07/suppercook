import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suppercook/core/app_providers.dart';
import 'package:suppercook/data/models/ingredient.dart';
import 'package:suppercook/data/models/localized_text.dart';
import 'package:suppercook/data/providers/pantry_provider.dart';
import 'package:suppercook/data/providers/planner_provider.dart';
import 'package:suppercook/data/providers/shopping_provider.dart';

ProviderContainer _container(SharedPreferences prefs) {
  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pantry additions survive a provider restart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final first = _container(prefs);
    addTearDown(first.dispose);
    first.read(pantryProvider.notifier).add(
      const Ingredient(
        id: 'persist_test',
        name: LocalizedText('Persist test', 'Persistenz-Test'),
        amount: 3,
        unit: 'pcs',
        category: IngredientCategory.produce,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final second = _container(prefs);
    addTearDown(second.dispose);
    expect(
      second.read(pantryProvider).any((item) => item.id == 'persist_test'),
      isTrue,
    );
  });

  test('shopping list state survives a provider restart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final first = _container(prefs);
    addTearDown(first.dispose);
    final itemId = first.read(shoppingProvider).first.id;
    first.read(shoppingProvider.notifier).toggle(itemId);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final second = _container(prefs);
    addTearDown(second.dispose);
    expect(
      second.read(shoppingProvider).firstWhere((item) => item.id == itemId).checked,
      isTrue,
    );
  });

  test('weekly planner survives a provider restart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final first = _container(prefs);
    addTearDown(first.dispose);
    first.read(plannerProvider.notifier).setMeal(6, 'dinner', 'salmon_bowl');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final second = _container(prefs);
    addTearDown(second.dispose);
    expect(second.read(plannerProvider)[6]?['dinner'], 'salmon_bowl');
  });
}
