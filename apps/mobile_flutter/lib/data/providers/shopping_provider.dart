import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock_data.dart';
import '../models/ingredient.dart';
import '../models/localized_text.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart';
import '../storage/app_storage.dart';

final shoppingProvider = NotifierProvider<ShoppingNotifier, List<ShoppingItem>>(
  ShoppingNotifier.new,
);

final shoppingProgressProvider = Provider<({int checked, int total})>((ref) {
  final items = ref.watch(shoppingProvider);
  return (
    checked: items.where((item) => item.checked).length,
    total: items.length,
  );
});

class ShoppingNotifier extends Notifier<List<ShoppingItem>> {
  @override
  List<ShoppingItem> build() {
    final storage = ref.watch(appStorageProvider);
    return storage.readShopping() ?? List.of(MockData.shoppingItems);
  }

  void _persist() => ref.read(appStorageProvider).writeShopping(state);

  void toggle(String id) {
    state = [
      for (final item in state)
        item.id == id ? item.copyWith(checked: !item.checked) : item,
    ];
    _persist();
  }

  /// Adds only the ingredients the user does not already have at home.
  /// Existing list entries are deduplicated by ingredient id.
  int addMissing(Recipe recipe, Set<String> pantryIds) {
    final missing = recipe.missing(pantryIds);
    final existingIds = state.map((item) => item.id).toSet();
    final additions = <ShoppingItem>[
      for (final ingredient in missing)
        if (!existingIds.contains(ingredient.id))
          ShoppingItem(
            id: ingredient.id,
            name: ingredient.name,
            category: ingredient.category,
            source: ingredient,
          ),
    ];
    if (additions.isEmpty) return 0;
    state = [...state, ...additions];
    _persist();
    return additions.length;
  }

  void addCustom(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    state = [
      ...state,
      ShoppingItem(
        id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
        name: LocalizedText.same(trimmed),
        category: IngredientCategory.other,
      ),
    ];
    _persist();
  }

  void clearChecked() {
    final next = state.where((item) => !item.checked).toList();
    if (next.length == state.length) return;
    state = next;
    _persist();
  }

  void remove(String id) {
    final next = state.where((item) => item.id != id).toList();
    if (next.length == state.length) return;
    state = next;
    _persist();
  }
}
