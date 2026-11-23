import 'recipe.dart';

/// Один слот недельного плана с сервера: день + приём пищи + снимок рецепта.
class PlannedMealSlot {
  final int day; // 0..6, понедельник = 0
  final String slot; // breakfast | lunch | dinner
  final Recipe recipe;

  const PlannedMealSlot({
    required this.day,
    required this.slot,
    required this.recipe,
  });
}
