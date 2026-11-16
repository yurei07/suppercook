import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart';
import 'api_mappers.dart';
import 'suppercook_api.dart';

class ApiException implements Exception {
  final String message;
  final Object? cause;

  const ApiException(this.message, [this.cause]);

  @override
  String toString() => 'ApiException: $message';
}

class ApiRepository {
  ApiRepository(this._api);

  final SuppercookApi _api;

  Future<bool> ping() => _api.ping();

  Future<List<Ingredient>> fetchPantry() async {
    try {
      final items = await _api.fetchInventory();
      return [for (final item in items) ApiMappers.inventoryItem(item)];
    } catch (error) {
      throw ApiException('Could not load the pantry', error);
    }
  }

  /// One-way sync from the local pantry to the API before asking for recipes.
  /// The API is still the source of truth for generation; this just makes sure
  /// it knows what the user has.
  Future<void> syncPantry(List<Ingredient> items, Locale locale) async {
    final existing = await _api.fetchInventory();
    final names = {
      for (final item in existing) item.name.toLowerCase(),
    };

    var pushed = 0;
    Object? lastError;

    for (final item in items) {
      final name = item.name.resolve(locale).trim();
      if (name.isEmpty || names.contains(name.toLowerCase())) continue;

      try {
        final (quantity, unit) = _apiQuantity(item);
        await _api.addInventoryItem(
          name: name,
          quantity: quantity,
          unit: unit,
        );
        names.add(name.toLowerCase());
        pushed++;
      } catch (error) {
        lastError = error;
      }
    }

    if (pushed == 0 && lastError != null) {
      throw ApiException('Could not sync the pantry with the API', lastError);
    }
  }

  Future<List<Recipe>> suggestRecipes({
    required Locale locale,
    required String goal,
    required List<String> allergies,
  }) async {
    try {
      final recipes = await _api.suggestRecipes(
        locale: locale.languageCode,
        diet: _diet(goal),
        allergens: allergies,
      );
      return [for (final recipe in recipes) ApiMappers.recipe(recipe)];
    } catch (error) {
      throw ApiException('Could not generate recipes', error);
    }
  }

  Future<List<Ingredient>> recognize({
    required Uint8List bytes,
    required String mimeType,
    required Locale locale,
  }) async {
    try {
      final items = await _api.recognize(
        bytes: bytes,
        mimeType: mimeType,
        locale: locale.languageCode,
      );
      return [for (final item in items) ApiMappers.recognizedItem(item)];
    } catch (error) {
      throw ApiException('Could not recognize the photo', error);
    }
  }

  Future<List<ShoppingItem>> fetchShopping() async {
    try {
      final items = await _api.fetchShopping();
      return [for (final item in items) ApiMappers.shoppingItem(item)];
    } catch (error) {
      throw ApiException('Could not load the shopping list', error);
    }
  }

  Future<void> addShoppingItem({
    required String name,
    required double quantity,
    required String unit,
  }) async {
    await _api.addShoppingItem(name: name, quantity: quantity, unit: unit);
  }

  /// Adds exactly what's missing from the recipe. The server deduplicates and
  /// skips anything the user already has in its inventory.
  Future<void> addMissingFromRecipe(
    Recipe recipe,
    Set<String> pantryIds,
    Locale locale,
  ) async {
    final missing = recipe.missing(pantryIds);
    if (missing.isEmpty) return;

    final strings = [
      for (final item in missing) _missingString(item, locale),
    ];
    await _api.addMissingFromRecipe(
      missingIngredients: strings,
      recipeId: recipe.id,
    );
  }

  Future<void> toggleShoppingItem(String id, bool checked) =>
      _api.toggleShoppingItem(id, checked);

  Future<void> removeShoppingItem(String id) => _api.removeShoppingItem(id);

  Future<void> clearCheckedShopping() => _api.clearCheckedShopping();

  String _missingString(Ingredient item, Locale locale) {
    final (quantity, unit) = _apiQuantity(item);
    final amount = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
    return '${item.name.resolve(locale)} ($amount $unit)';
  }

  (double, String) _apiQuantity(Ingredient item) {
    final amount = item.amount;
    return switch (item.unit) {
      'g' => (amount, 'g'),
      'ml' => (amount, 'ml'),
      'pcs' => (amount, 'pcs'),
      'clove' => (amount * 5, 'g'),
      'tbsp' => (amount * 15, 'g'),
      'tsp' => (amount * 5, 'g'),
      'bunch' => (amount * 30, 'g'),
      'pinch' => (amount, 'g'),
      'slice' => (amount * 30, 'g'),
      _ => (amount, 'g'),
    };
  }

  String _diet(String goal) {
    return switch (goal) {
      'lose' => 'lose_weight',
      'gain' => 'gain_weight',
      _ => 'maintain',
    };
  }
}
