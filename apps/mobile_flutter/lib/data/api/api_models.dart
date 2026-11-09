Map<String, dynamic> _asMap(Object? value) =>
    Map<String, dynamic>.from(value as Map);

List<dynamic> _asList(Object? value) =>
    value is List ? value : const <dynamic>[];

String _asString(Object? value, [String fallback = '']) =>
    value is String ? value : fallback;

double _asDouble(Object? value) =>
    value is num ? value.toDouble() : 0;

int _asInt(Object? value) => value is num ? value.toInt() : 0;

class ApiInventoryItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;

  const ApiInventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory ApiInventoryItem.fromJson(Map<String, dynamic> json) =>
      ApiInventoryItem(
        id: _asString(json['id']),
        name: _asString(json['name']),
        quantity: _asDouble(json['quantity']),
        unit: _asString(json['unit'], 'g'),
      );
}

class ApiIngredient {
  final String name;
  final double quantity;
  final String unit;
  final bool? have;

  const ApiIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.have,
  });

  factory ApiIngredient.fromJson(Map<String, dynamic> json) => ApiIngredient(
    name: _asString(json['name']),
    quantity: _asDouble(json['quantity']),
    unit: _asString(json['unit'], 'g'),
    have: json['have'] is bool ? json['have'] as bool : null,
  );
}

class ApiNutrition {
  final int kcal;
  final int protein;
  final int carbs;
  final int fat;

  const ApiNutrition({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory ApiNutrition.fromJson(Map<String, dynamic> json) => ApiNutrition(
    kcal: _asInt(json['kcal']),
    protein: _asInt(json['protein']),
    carbs: _asInt(json['carbs']),
    fat: _asInt(json['fat']),
  );
}

class ApiRecipe {
  final String id;
  final String title;
  final String description;
  final String image;
  final int servings;
  final int timeMinutes;
  final String difficulty;
  final List<ApiIngredient> ingredients;
  final List<String> steps;
  final ApiNutrition nutrition;
  final List<String> tags;

  const ApiRecipe({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.servings,
    required this.timeMinutes,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
    required this.nutrition,
    required this.tags,
  });

  factory ApiRecipe.fromJson(Map<String, dynamic> json) => ApiRecipe(
    id: _asString(json['id']),
    title: _asString(json['title']),
    description: _asString(json['description']),
    image: _asString(json['image'], 'shared_table'),
    servings: _asInt(json['servings']),
    timeMinutes: _asInt(json['timeMinutes']),
    difficulty: _asString(json['difficulty'], 'easy'),
    ingredients: [
      for (final item in _asList(json['ingredients']))
        ApiIngredient.fromJson(_asMap(item)),
    ],
    steps: [for (final item in _asList(json['steps'])) item.toString()],
    nutrition: ApiNutrition.fromJson(_asMap(json['nutrition'] ?? const {})),
    tags: [for (final item in _asList(json['tags'])) item.toString()],
  );
}

class ApiRecognitionItem {
  final String name;
  final double quantity;
  final String unit;
  final double confidence;

  const ApiRecognitionItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.confidence,
  });

  factory ApiRecognitionItem.fromJson(Map<String, dynamic> json) =>
      ApiRecognitionItem(
        name: _asString(json['name']),
        quantity: _asDouble(json['quantity']),
        unit: _asString(json['unit'], 'g'),
        confidence: _asDouble(json['confidence']),
      );
}
