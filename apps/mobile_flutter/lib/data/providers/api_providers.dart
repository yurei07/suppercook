import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale_controller.dart';
import '../api/api_config.dart';
import '../api/api_repository.dart';
import '../api/suppercook_api.dart';
import '../models/recipe.dart';
import '../models/shopping_item.dart';
import 'auth_provider.dart';
import 'data_source_provider.dart';
import 'pantry_provider.dart';
import 'recipe_provider.dart';
import 'shopping_provider.dart';
import 'user_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final locale = ref.watch(localeProvider);
  final session = ref.watch(authProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        if (session != null)
          'Authorization': 'Bearer ${session.token}'
        else
          // Гостевой режим: legacy-заголовок, у каждого языка свой набор данных.
          'x-user-id': 'demo-user-${locale.languageCode}',
        'Accept-Language': locale.languageCode,
      },
    ),
  );
  ref.onDispose(() => dio.close(force: true));
  return dio;
});

final suppercookApiProvider = Provider<SuppercookApi>(
  (ref) => SuppercookApi(ref.watch(dioProvider)),
);

final apiRepositoryProvider = Provider<ApiRepository>(
  (ref) => ApiRepository(ref.watch(suppercookApiProvider)),
);

/// Recipes for the suggestions screen.
///
/// Demo mode returns the local catalog immediately. API mode syncs the pantry
/// one way (local → backend), asks for recipes, and caches them so the detail
/// screen can find them by id.
final suggestionsFeedProvider = FutureProvider<List<Recipe>>((ref) async {
  final source = ref.watch(dataSourceProvider);
  final locale = ref.watch(localeProvider);

  if (source == DataSource.demo) {
    return ref.watch(suggestionsProvider);
  }

  final repository = ref.watch(apiRepositoryProvider);
  final pantry = ref.watch(pantryProvider);
  final profile = ref.watch(userProfileProvider);

  await repository.syncPantry(pantry, locale);
  final recipes = await repository.suggestRecipes(
    locale: locale,
    goal: profile.goal,
    allergies: profile.allergies,
  );
  ref.read(remoteRecipesProvider.notifier).putAll(recipes);
  return recipes;
});

/// Shopping list for the current data source. Demo mode mirrors the local
/// notifier; Live API mode reads the backend list.
final apiShoppingProvider = FutureProvider<List<ShoppingItem>>((ref) async {
  final source = ref.watch(dataSourceProvider);
  if (source == DataSource.demo) {
    return ref.watch(shoppingProvider);
  }
  return ref.watch(apiRepositoryProvider).fetchShopping();
});

/// Live API режим: подтягиваем инвентарь с сервера и добавляем в кладовку
/// то, чего локально ещё нет (например, добавленное с другого устройства).
/// Существующие позиции не трогаем — локальные правки не затираются.
final pantrySyncProvider = FutureProvider<int>((ref) async {
  final source = ref.watch(dataSourceProvider);
  if (source == DataSource.demo) return 0;

  final remote = await ref.watch(apiRepositoryProvider).fetchPantry();
  var added = 0;
  for (final item in remote) {
    final alreadyHere = ref
        .read(pantryProvider)
        .any((existing) => existing.id == item.id);
    if (!alreadyHere) {
      ref.read(pantryProvider.notifier).add(item);
      added++;
    }
  }
  return added;
});
