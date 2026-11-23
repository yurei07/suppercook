import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suppercook/core/app_providers.dart';
import 'package:suppercook/data/mock_data.dart';
import 'package:suppercook/data/providers/saved_provider.dart';
import 'package:suppercook/data/storage/app_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer makeContainer(SharedPreferences prefs) {
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('toggle сохраняет и убирает рецепт, переживая рестарт контейнера', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = makeContainer(prefs);
    final recipe = MockData.recipes.first;

    container.read(savedRecipesProvider.notifier).toggle(recipe);
    expect(container.read(savedRecipesProvider).keys, [recipe.id]);

    // Новый контейнер = перезапуск приложения: избранное восстанавливается
    final container2 = makeContainer(prefs);
    expect(container2.read(savedRecipesProvider).keys, [recipe.id]);
    expect(container2.read(savedRecipesProvider.notifier).isSaved(recipe.id), isTrue);

    container2.read(savedRecipesProvider.notifier).toggle(recipe);
    expect(container2.read(savedRecipesProvider), isEmpty);
  });

  test('mergeFromServer добавляет только серверное, локальное не трогает', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = makeContainer(prefs);
    final local = MockData.recipes.first;
    final remote = MockData.recipes[1];

    container.read(savedRecipesProvider.notifier).toggle(local);

    container.read(savedRecipesProvider.notifier).mergeFromServer({
      local.id: local,
      remote.id: remote,
    });

    final saved = container.read(savedRecipesProvider);
    expect(saved.keys.toSet(), {local.id, remote.id});
    expect(saved[local.id], same(local));
  });

  test('избранное сохраняется локально через AppStorage', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = makeContainer(prefs);
    final recipe = MockData.recipes.first;

    container.read(savedRecipesProvider.notifier).toggle(recipe);

    final storage = container.read(appStorageProvider);
    expect(storage.readSavedRecipes()!.keys, [recipe.id]);
  });
}
