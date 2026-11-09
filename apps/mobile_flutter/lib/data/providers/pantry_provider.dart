import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock_data.dart';
import '../models/ingredient.dart';

final pantryProvider = NotifierProvider<PantryNotifier, List<Ingredient>>(
  PantryNotifier.new,
);

final pantryIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(pantryProvider).map((item) => item.id).toSet();
});

class PantryNotifier extends Notifier<List<Ingredient>> {
  @override
  List<Ingredient> build() => List.of(MockData.pantryItems);

  void add(Ingredient item) {
    if (state.any((existing) => existing.id == item.id)) return;
    state = [...state, item];
  }

  void addAll(Iterable<Ingredient> items) {
    final byId = {for (final item in state) item.id: item};
    for (final item in items) {
      byId[item.id] = item;
    }
    state = byId.values.toList();
  }

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void toggle(Ingredient item) {
    if (state.any((existing) => existing.id == item.id)) {
      remove(item.id);
    } else {
      add(item);
    }
  }

  bool contains(String id) => state.any((item) => item.id == id);
}
