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

  /// Полный снимок для сервера (планировщик). Обратим через fromJson —
  /// план должен восстанавливаться после рестарта без каталога рецептов.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title.toJson(),
    'description': description.toJson(),
    'image': image,
    'minutes': minutes,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'servings': servings,
    'difficulty': difficulty.name,
    'tags': [for (final tag in tags) tag.name],
    'ingredients': [for (final item in ingredients) item.toJson()],
    'steps': [
      for (final step in steps)
        {
          'title': step.title.toJson(),
          'body': step.body.toJson(),
          'timerMinutes': step.timerMinutes,
        },
    ],
  };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] as String? ?? '',
    title: LocalizedText.fromJson(_map(json['title'])),
    description: LocalizedText.fromJson(_map(json['description'])),
    image: json['image'] as String? ?? 'assets/images/food/shared_table.jpg',
    minutes: (json['minutes'] as num?)?.toInt() ?? 0,
    calories: (json['calories'] as num?)?.toInt() ?? 0,
    protein: (json['protein'] as num?)?.toInt() ?? 0,
    carbs: (json['carbs'] as num?)?.toInt() ?? 0,
    fat: (json['fat'] as num?)?.toInt() ?? 0,
    servings: (json['servings'] as num?)?.toInt() ?? 2,
    difficulty: RecipeDifficulty.values.firstWhere(
      (value) => value.name == json['difficulty'],
      orElse: () => RecipeDifficulty.easy,
    ),
    tags: RecipeTag.values
        .where(
          (value) =>
              (json['tags'] as List<dynamic>? ?? const []).contains(value.name),
        )
        .toList(),
    ingredients: [
      for (final item in (json['ingredients'] as List<dynamic>? ?? const []))
        Ingredient.fromJson(Map<String, dynamic>.from(item as Map)),
    ],
    steps: [
      for (final item in (json['steps'] as List<dynamic>? ?? const []))
        RecipeStep(
          title: LocalizedText.fromJson(_map((item as Map)['title'])),
          body: LocalizedText.fromJson(_map(item['body'])),
          timerMinutes: (item['timerMinutes'] as num?)?.toInt(),
        ),
    ],
  );

  static Map<String, dynamic> _map(Object? value) =>
      Map<String, dynamic>.from((value as Map?) ?? const {});
}
