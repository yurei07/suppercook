import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock_data.dart';
import '../models/recipe.dart';
import 'pantry_provider.dart';

final recipesProvider = Provider<List<Recipe>>((ref) => MockData.recipes);

final featuredRecipesProvider = Provider<List<Recipe>>((ref) {
  final recipes = ref.watch(recipesProvider);
  return [
    for (final id in MockData.featuredRecipeIds)
      ...recipes.where((recipe) => recipe.id == id),
  ];
});

final recipeByIdProvider = Provider.family<Recipe?, String>((ref, id) {
  final recipes = ref.watch(recipesProvider);
  for (final recipe in recipes) {
    if (recipe.id == id) return recipe;
  }
  return null;
});

/// All recipes ordered by how well they match the current pantry.
final suggestionsProvider = Provider<List<Recipe>>((ref) {
  final pantryIds = ref.watch(pantryIdsProvider);
  final recipes = [...ref.watch(recipesProvider)];
  recipes.sort(
    (a, b) => b.matchPercent(pantryIds).compareTo(a.matchPercent(pantryIds)),
  );
  return recipes;
});
