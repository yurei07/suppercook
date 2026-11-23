import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recipe.dart';
import '../storage/app_storage.dart';
import 'api_providers.dart';
import 'data_source_provider.dart';
import 'recipe_provider.dart';

/// Избранные рецепты: recipeId → снимок. Локально всегда, в Live API режиме
/// дублируется на сервер (там рецепт хранится целиком и переживает рестарт).
final savedRecipesProvider =
    NotifierProvider<SavedRecipesNotifier, Map<String, Recipe>>(
      SavedRecipesNotifier.new,
    );

class SavedRecipesNotifier extends Notifier<Map<String, Recipe>> {
  @override
  Map<String, Recipe> build() {
    return ref.watch(appStorageProvider).readSavedRecipes() ?? const {};
  }

  void _persist() =>
      ref.read(appStorageProvider).writeSavedRecipes(state);

  bool isSaved(String recipeId) => state.containsKey(recipeId);

  void toggle(Recipe recipe) {
    if (isSaved(recipe.id)) {
      final updated = {...state}..remove(recipe.id);
      state = updated;
      _persist();
      if (!_live) return;
      unawaited(
        _guard(
          () => ref
              .read(apiRepositoryProvider)
              .unsaveRecipe(recipe.id),
        ),
      );
    } else {
      state = {...state, recipe.id: recipe};
      _persist();
      if (!_live) return;
      unawaited(
        _guard(
          () => ref.read(apiRepositoryProvider).saveRecipe(recipe),
        ),
      );
    }
  }

  /// Сервер прислал избранное (Live API режим) — добавляем локально
  /// недостающее, свои правки не затираем.
  void mergeFromServer(Map<String, Recipe> recipes) {
    final merged = {...state};
    var changed = false;
    for (final entry in recipes.entries) {
      if (!merged.containsKey(entry.key)) {
        merged[entry.key] = entry.value;
        changed = true;
      }
    }
    if (!changed) return;
    state = merged;
    _persist();
  }

  bool get _live => ref.read(dataSourceProvider) == DataSource.api;

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Офлайн — избранное уже сохранено локально.
    }
  }
}

/// Тянет избранное с сервера и восстанавливает снимки в кэш рецептов,
/// чтобы карточки открывались после рестарта.
final savedSyncProvider = FutureProvider<int>((ref) async {
  final source = ref.watch(dataSourceProvider);
  if (source == DataSource.demo) return 0;

  final saved = await ref.watch(apiRepositoryProvider).fetchSavedRecipes();
  ref.read(remoteRecipesProvider.notifier).putAll(saved.values);
  ref.read(savedRecipesProvider.notifier).mergeFromServer(saved);
  return saved.length;
});
