import 'ingredient.dart';
import 'localized_text.dart';

enum RecipeDifficulty { easy, medium, hard }

enum RecipeTag { quick, vegan, vegetarian, highProtein, glutenFree, breakfast }

class RecipeStep {
  final LocalizedText title;
  final LocalizedText body;
  final int? timerMinutes;

  const RecipeStep({
    required this.title,
    required this.body,
    this.timerMinutes,
  });
}

class Recipe {
  final String id;
  final LocalizedText title;
  final LocalizedText description;
  final String image;
  final int minutes;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int servings;
  final RecipeDifficulty difficulty;
  final List<RecipeTag> tags;
  final List<Ingredient> ingredients;
  final List<RecipeStep> steps;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.minutes,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servings,
    required this.difficulty,
    required this.tags,
    required this.ingredients,
    required this.steps,
  });

  int matchPercent(Set<String> pantryIds) {
    if (ingredients.isEmpty) return 0;
    final available = ingredients.where((i) => pantryIds.contains(i.id)).length;
    return ((available / ingredients.length) * 100).round().clamp(0, 100);
  }

  List<Ingredient> missing(Set<String> pantryIds) =>
      ingredients.where((i) => !pantryIds.contains(i.id)).toList();

  bool get isVegan => tags.contains(RecipeTag.vegan);
  bool get isQuick => tags.contains(RecipeTag.quick);
  bool get isHighProtein => tags.contains(RecipeTag.highProtein);
}
