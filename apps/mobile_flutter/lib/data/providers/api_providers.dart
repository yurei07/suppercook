import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale_controller.dart';
import '../api/api_config.dart';
import '../api/api_repository.dart';
import '../api/suppercook_api.dart';
import '../models/recipe.dart';
import 'data_source_provider.dart';
import 'pantry_provider.dart';
import 'recipe_provider.dart';
import 'user_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final locale = ref.watch(localeProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        // Keep API inventories separate per language until real auth exists.
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
