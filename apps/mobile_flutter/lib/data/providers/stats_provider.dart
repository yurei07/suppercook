import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_providers.dart';
import '../../core/preferences.dart';

final recipesCookedProvider = NotifierProvider<RecipesCookedNotifier, int>(
  RecipesCookedNotifier.new,
);

class RecipesCookedNotifier extends Notifier<int> {
  @override
  int build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getInt(recipesCookedKey) ?? 0;
  }

  Future<void> increment() async {
    state = state + 1;
    await ref
        .read(sharedPreferencesProvider)
        .setInt(recipesCookedKey, state);
  }
}
