import '../mock_data.dart';
import '../models/ingredient.dart';
import '../models/localized_text.dart';
import '../models/recipe.dart';
import 'api_models.dart';

abstract final class ApiMappers {
  static const _knownImages = {
    'shared_table',
    'salmon_bowl',
    'tomato_pasta',
    'green_salad',
    'pumpkin_soup',
    'mushroom_pizza',
    'berry_pancakes',
    'avocado_toast',
    'omelette',
    'fried_eggs',
    'harvest_bowl',
    'caesar_salad',
  };

  static String imageAsset(String key) {
    final clean = key.split('/').last.split('.').first;
    final safe = _knownImages.contains(clean) ? clean : 'shared_table';
    return 'assets/images/food/$safe.jpg';
  }

  static Recipe recipe(ApiRecipe dto) {
    return Recipe(
      id: dto.id,
      title: LocalizedText.same(dto.title),
      description: LocalizedText.same(dto.description),
      image: imageAsset(dto.image),
      minutes: dto.timeMinutes,
      calories: dto.nutrition.kcal,
      protein: dto.nutrition.protein,
      carbs: dto.nutrition.carbs,
      fat: dto.nutrition.fat,
      servings: dto.servings,
      difficulty: _difficulty(dto.difficulty),
      tags: _tags(dto.tags),
      ingredients: [
        for (final item in dto.ingredients)
          ingredient(item.name, item.quantity, item.unit),
      ],
      steps: [
        for (var index = 0; index < dto.steps.length; index++)
          RecipeStep(
            title: LocalizedText(
              'Step ${index + 1}',
              'Schritt ${index + 1}',
            ),
            body: LocalizedText.same(dto.steps[index]),
          ),
      ],
    );
  }

  static Ingredient ingredient(String name, double amount, String unit) {
    final known = MockData.findIngredient(name);
    if (known != null) {
      return Ingredient(
        id: known.id,
        name: known.name,
        amount: amount,
        unit: unit,
        category: known.category,
      );
    }

    return Ingredient(
      id: _slug(name),
      name: LocalizedText.same(name),
      amount: amount,
      unit: unit,
      category: _category(name),
    );
  }

  static Ingredient inventoryItem(ApiInventoryItem item) =>
      ingredient(item.name, item.quantity, item.unit);

  static Ingredient recognizedItem(ApiRecognitionItem item) =>
      ingredient(item.name, item.quantity, item.unit);

  static RecipeDifficulty _difficulty(String raw) {
    return switch (raw.toLowerCase()) {
      'medium' => RecipeDifficulty.medium,
      'hard' => RecipeDifficulty.hard,
      _ => RecipeDifficulty.easy,
    };
  }

  static List<RecipeTag> _tags(List<String> rawTags) {
    final tags = <RecipeTag>{};
    for (final raw in rawTags) {
      final tag = raw.toLowerCase();
      if (tag.contains('vegan')) {
        tags.add(RecipeTag.vegan);
      } else if (tag.contains('vegetarian') || tag.contains('vegetarisch')) {
        tags.add(RecipeTag.vegetarian);
      }
      if (tag.contains('breakfast') ||
          tag.contains('frühstück') ||
          tag.contains('fruhstuck')) {
        tags.add(RecipeTag.breakfast);
      }
      if (tag.contains('quick') ||
          tag.contains('schnell') ||
          tag.contains('fast')) {
        tags.add(RecipeTag.quick);
      }
      if (tag.contains('protein')) {
        tags.add(RecipeTag.highProtein);
      }
      if (tag.contains('gluten')) {
        tags.add(RecipeTag.glutenFree);
      }
    }
    return tags.toList();
  }

  static String _slug(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss');
    final slug = normalized
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return slug.isEmpty ? 'custom' : slug;
  }

  static IngredientCategory _category(String name) {
    final lower = name.toLowerCase();
    if (RegExp(
      r'(tomato|tomate|onion|zwiebel|garlic|knoblauch|potato|kartoffel|cucumber|gurke|lemon|zitrone|avocado|spinach|spinat|mushroom|pilz|pumpkin|kürbis|zucchini|pepper|paprika|berry|beere|parsley|petersilie|basil|basilikum|arugula|rucola|ginger|ingwer|fruit|gemüse|vegetable)',
    ).hasMatch(lower)) {
      return IngredientCategory.produce;
    }
    if (RegExp(
      r'(milk|milch|cheese|käse|butter|cream|sahne|egg|ei|yogurt|joghurt|feta|parmesan|mozzarella)',
    ).hasMatch(lower)) {
      return IngredientCategory.dairy;
    }
    if (RegExp(
      r'(oil|öl|flour|mehl|pasta|rice|reis|quinoa|couscous|broth|brühe|sauce|syrup|sirup|chickpea|kichererbse|bean|bohne|tahini|tahin|spice|gewürz|salt|salz)',
    ).hasMatch(lower)) {
      return IngredientCategory.pantry;
    }
    return IngredientCategory.other;
  }
}
