import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock_data.dart';
import '../models/ingredient.dart';
import '../storage/app_storage.dart';

final pantryProvider = NotifierProvider<PantryNotifier, List<Ingredient>>(
  PantryNotifier.new,
);

final pantryIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(pantryProvider).map((item) => item.id).toSet();
});

class PantryNotifier extends Notifier<List<Ingredient>> {
  @override
  List<Ingredient> build() {
    final storage = ref.watch(appStorageProvider);
    return storage.readPantry() ?? List.of(MockData.pantryItems);
  }

  void _persist() => ref.read(appStorageProvider).writePantry(state);

  void add(Ingredient item) {
    if (state.any((existing) => existing.id == item.id)) return;
    state = [...state, item];
    _persist();
  }

  void addAll(Iterable<Ingredient> items) {
    final byId = {for (final item in state) item.id: item};
    var changed = false;
    for (final item in items) {
      if (byId[item.id] == null) changed = true;
      byId[item.id] = item;
    }
    if (!changed) return;
    state = byId.values.toList();
    _persist();
  }

  void remove(String id) {
    final next = state.where((item) => item.id != id).toList();
    if (next.length == state.length) return;
    state = next;
    _persist();
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
