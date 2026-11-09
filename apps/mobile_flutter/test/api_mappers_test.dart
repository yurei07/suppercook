import 'package:flutter_test/flutter_test.dart';
import 'package:suppercook/data/api/api_mappers.dart';
import 'package:suppercook/data/api/api_models.dart';
import 'package:suppercook/data/models/recipe.dart';

void main() {
  test('maps an API recipe into the local domain model', () {
    final dto = ApiRecipe.fromJson({
      'id': 'recipe-1',
      'title': 'Tomato & Cheese Omelette',
      'description': 'A fluffy breakfast omelette.',
      'image': 'avocado_toast',
      'servings': 2,
      'timeMinutes': 10,
      'difficulty': 'easy',
      'ingredients': [
        {'name': 'eggs', 'quantity': 240, 'unit': 'g', 'have': true},
        {'name': 'tomatoes', 'quantity': 150, 'unit': 'g', 'have': true},
        {'name': 'cheese', 'quantity': 60, 'unit': 'g', 'have': false},
      ],
      'steps': ['Whisk the eggs.', 'Cook the omelette.'],
      'nutrition': {'kcal': 320, 'protein': 22, 'carbs': 6, 'fat': 23},
      'tags': ['breakfast', 'quick', 'vegetarian'],
    });

    final recipe = ApiMappers.recipe(dto);

    expect(recipe.id, 'recipe-1');
    expect(recipe.title.en, 'Tomato & Cheese Omelette');
    expect(recipe.image, endsWith('avocado_toast.jpg'));
    expect(recipe.minutes, 10);
    expect(recipe.calories, 320);
    expect(recipe.steps, hasLength(2));
    expect(recipe.tags, contains(RecipeTag.breakfast));
    expect(recipe.tags, contains(RecipeTag.quick));
    expect(recipe.tags, contains(RecipeTag.vegetarian));
    expect(recipe.ingredients[0].id, 'eggs');
    expect(recipe.ingredients[1].id, 'tomato');
    expect(recipe.ingredients[2].id, 'cheese');
    expect(recipe.missing({'eggs', 'tomato'}), hasLength(1));
  });

  test('maps German recognition names to local ingredient ids', () {
    final item = ApiMappers.recognizedItem(
      ApiRecognitionItem.fromJson({
        'name': 'Eier',
        'quantity': 4,
        'unit': 'pcs',
        'confidence': 0.95,
      }),
    );

    expect(item.id, 'eggs');
    expect(item.name.en, 'Eggs');
    expect(item.name.de, 'Eier');
  });

  test('falls back to a known image for unknown API keys', () {
    expect(ApiMappers.imageAsset('unknown_image'), endsWith('shared_table.jpg'));
    expect(ApiMappers.imageAsset('pumpkin_soup'), endsWith('pumpkin_soup.jpg'));
  });
}
