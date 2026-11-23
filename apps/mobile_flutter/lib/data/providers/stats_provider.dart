import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_providers.dart';
import '../../core/preferences.dart';
import 'api_providers.dart';
import 'data_source_provider.dart';

final recipesCookedProvider = NotifierProvider<RecipesCookedNotifier, int>(
  RecipesCookedNotifier.new,
);

class RecipesCookedNotifier extends Notifier<int> {
  @override
  int build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getInt(recipesCookedKey) ?? 0;
  }

  Future<void> increment({String? recipeId, String? title}) async {
    state = state + 1;
    await ref
        .read(sharedPreferencesProvider)
        .setInt(recipesCookedKey, state);

    // Live API режим: пишем приготовление в историю на сервере.
    if (recipeId != null &&
        ref.read(dataSourceProvider) == DataSource.api) {
      try {
        await ref
            .read(apiRepositoryProvider)
            .markCooked(recipeId: recipeId, title: title ?? recipeId);
      } catch (_) {
        // Офлайн — счётчик локальный, запись в историю пропустим.
      }
    }
  }

  /// Сервер знает больше приготовлений — принимаем его счётчик.
  Future<void> adoptMax(int serverCount) async {
    if (serverCount <= state) return;
    state = serverCount;
    await ref
        .read(sharedPreferencesProvider)
        .setInt(recipesCookedKey, state);
  }
}

/// Live API режим: сверяем локальный счётчик с историей на сервере.
final cookedSyncProvider = FutureProvider<int>((ref) async {
  final source = ref.watch(dataSourceProvider);
  if (source == DataSource.demo) return ref.watch(recipesCookedProvider);

  final serverCount = await ref.watch(apiRepositoryProvider).fetchCookedCount();
  final local = ref.watch(recipesCookedProvider);
  if (serverCount > local) {
    await ref.read(recipesCookedProvider.notifier).adoptMax(serverCount);
  }
  return serverCount > local ? serverCount : local;
});
