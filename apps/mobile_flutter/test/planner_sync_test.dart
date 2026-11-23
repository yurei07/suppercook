import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suppercook/core/app_providers.dart';
import 'package:suppercook/data/mock_data.dart';
import 'package:suppercook/data/models/recipe.dart';
import 'package:suppercook/data/providers/planner_provider.dart';
import 'package:suppercook/data/storage/app_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Recipe.toJson/fromJson', () {
    test('демо-рецепт переживает полный раундтрип', () {
      final original = MockData.recipes.first;

      final restored = Recipe.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.title.en, original.title.en);
      expect(restored.title.de, original.title.de);
      expect(restored.description.en, original.description.en);
      expect(restored.image, original.image);
      expect(restored.minutes, original.minutes);
      expect(restored.calories, original.calories);
      expect(restored.protein, original.protein);
      expect(restored.carbs, original.carbs);
      expect(restored.fat, original.fat);
      expect(restored.servings, original.servings);
      expect(restored.difficulty, original.difficulty);
      expect(restored.tags, original.tags);
      expect(restored.ingredients.length, original.ingredients.length);
      expect(restored.ingredients.first.id, original.ingredients.first.id);
      expect(
        restored.ingredients.first.name.en,
        original.ingredients.first.name.en,
      );
      expect(restored.steps.length, original.steps.length);
      expect(restored.steps.first.title.en, original.steps.first.title.en);
      expect(restored.steps.first.body.en, original.steps.first.body.en);
      expect(
        restored.steps.first.timerMinutes,
        original.steps.first.timerMinutes,
      );
    });

    test('битые/пустые поля не роняют разбор', () {
      final recipe = Recipe.fromJson(const {
        'id': 'r1',
        'title': {'en': 'Soup'},
        'tags': ['quick', 'nonsense_tag'],
        'ingredients': [],
        'steps': [],
      });

      expect(recipe.title.en, 'Soup');
      expect(recipe.difficulty, RecipeDifficulty.easy);
      expect(recipe.tags, [RecipeTag.quick]);
      expect(recipe.minutes, 0);
    });
  });

  group('PlannerNotifier', () {
    test('removeMeal убирает блюдо из слота', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(plannerProvider.notifier);
      notifier.setMeal(5, 'dinner', 'berry_pancakes');
      expect(container.read(plannerProvider)[5]?['dinner'], 'berry_pancakes');

      notifier.removeMeal(5, 'dinner');
      expect(
        container.read(plannerProvider)[5]?.containsKey('dinner') ?? false,
        isFalse,
      );
    });

    test('loadFromServer заменяет план и не трогает сервер обратно', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      container.read(plannerProvider.notifier).loadFromServer({
        2: {'dinner': 'tomato_pasta'},
      });

      final plan = container.read(plannerProvider);
      expect(plan, {2: {'dinner': 'tomato_pasta'}});
      // План сохранился локально
      final storage = container.read(appStorageProvider);
      expect(storage.readPlan(currentWeekStart()), plan);
    });
  });
}
