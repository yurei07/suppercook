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

/// API recipes are generated on demand, so they don't live in the local
/// catalog. The suggestions screen puts them here before the user can open one.
final remoteRecipesProvider =
    NotifierProvider<RemoteRecipesNotifier, Map<String, Recipe>>(
      RemoteRecipesNotifier.new,
    );

class RemoteRecipesNotifier extends Notifier<Map<String, Recipe>> {
  @override
  Map<String, Recipe> build() => const {};

  void putAll(Iterable<Recipe> recipes) {
    state = {
      ...state,
      for (final recipe in recipes) recipe.id: recipe,
    };
  }

  void clear() => state = const {};
}

final recipeByIdProvider = Provider.family<Recipe?, String>((ref, id) {
  final recipes = ref.watch(recipesProvider);
  for (final recipe in recipes) {
    if (recipe.id == id) return recipe;
  }
  return ref.watch(remoteRecipesProvider)[id];
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
