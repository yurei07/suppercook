import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/planned_meal.dart';
import '../models/recipe.dart';
import '../storage/app_storage.dart';
import 'api_providers.dart';
import 'data_source_provider.dart';
import 'recipe_provider.dart';

/// ISO-дата понедельника текущей недели — единая точка отсчёта для
/// локального хранения и API.
DateTime currentWeekStart() {
  final now = DateTime.now();
  return DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: now.weekday - 1));
}

/// Weekly plan: weekday index (0 = Monday) → meal key → recipe id.
final plannerProvider =
    NotifierProvider<PlannerNotifier, Map<int, Map<String, String>>>(
      PlannerNotifier.new,
    );

class PlannerNotifier
    extends Notifier<Map<int, Map<String, String>>> {
  late DateTime _weekStart;

  static const _defaultPlan = <int, Map<String, String>>{
    0: {
      'breakfast': 'berry_pancakes',
      'lunch': 'green_salad',
      'dinner': 'salmon_bowl',
    },
    1: {'breakfast': 'avocado_toast', 'dinner': 'tomato_pasta'},
    2: {'lunch': 'harvest_bowl', 'dinner': 'mushroom_pizza'},
    3: {
      'breakfast': 'berry_pancakes',
      'lunch': 'tomato_pasta',
      'dinner': 'pumpkin_soup',
    },
    4: {'dinner': 'mushroom_pizza'},
  };

  @override
  Map<int, Map<String, String>> build() {
    _weekStart = currentWeekStart();

    final storage = ref.watch(appStorageProvider);
    final stored = storage.readPlan(_weekStart);
    if (stored != null) return stored;

    return {
      for (final entry in _defaultPlan.entries)
        entry.key: Map<String, String>.from(entry.value),
    };
  }

  void _persist() => ref.read(appStorageProvider).writePlan(_weekStart, state);

  void setMeal(int day, String meal, String recipeId) {
    final updated = <int, Map<String, String>>{
      for (final entry in state.entries)
        entry.key: Map<String, String>.from(entry.value),
    };
    updated[day] = {...?updated[day], meal: recipeId};
    state = updated;
    _persist();
    _pushSlot(day, meal, recipeId);
  }

  /// Сервер прислал план (Live API режим) — применяем без обратного пуша.
  void loadFromServer(Map<int, Map<String, String>> plan) {
    state = {
      for (final entry in plan.entries)
        entry.key: Map<String, String>.from(entry.value),
    };
    _persist();
  }

  void replaceAll(Map<int, Map<String, String>> plan) {
    state = {
      for (final entry in plan.entries)
        entry.key: Map<String, String>.from(entry.value),
    };
    _persist();
    _pushWholeWeek();
  }

  void removeMeal(int day, String meal) {
    final updated = <int, Map<String, String>>{
      for (final entry in state.entries)
        entry.key: Map<String, String>.from(entry.value),
    };
    updated[day]?.remove(meal);
    if (updated[day]?.isEmpty ?? false) updated.remove(day);
    state = updated;
    _persist();
    if (!_live) return;
    final week = AppStorage.dateKey(_weekStart);
    unawaited(
      _guard(
        () => ref.read(apiRepositoryProvider).clearPlannerMeal(week, day, meal),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Push в Live API режиме. Ошибки глотаем сознательно: план остаётся
  // локальным и синкается при следующей удачной попытке.
  // ---------------------------------------------------------------------------

  bool get _live => ref.read(dataSourceProvider) == DataSource.api;

  Recipe? _recipeById(String id) {
    for (final recipe in ref.read(recipesProvider)) {
      if (recipe.id == id) return recipe;
    }
    return ref.read(remoteRecipesProvider)[id];
  }

  void _pushSlot(int day, String meal, String recipeId) {
    if (!_live) return;
    final recipe = _recipeById(recipeId);
    if (recipe == null) return;
    final week = AppStorage.dateKey(_weekStart);
    unawaited(
      _guard(
        () => ref
            .read(apiRepositoryProvider)
            .upsertPlannerMeal(week, day, meal, recipe),
      ),
    );
  }

  void _pushWholeWeek() {
    if (!_live) return;
    final week = AppStorage.dateKey(_weekStart);
    final meals = <(int, String, Recipe)>[
      for (final entry in state.entries)
        for (final slot in entry.value.entries)
          if (_recipeById(slot.value) case final recipe?)
            (entry.key, slot.key, recipe),
    ];
    unawaited(
      _guard(
        () => ref.read(apiRepositoryProvider).replaceWeekPlan(week, meals),
      ),
    );
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Офлайн — план уже сохранён локально.
    }
  }
}

/// Тянет план с сервера в Live API режиме и восстанавливает снимки рецептов
/// в кэш, чтобы карточки и детали открывались после рестарта.
final plannerSyncProvider = FutureProvider<List<PlannedMealSlot>>((ref) async {
  final source = ref.watch(dataSourceProvider);
  if (source == DataSource.demo) return const [];

  final week = AppStorage.dateKey(currentWeekStart());
  final meals = await ref.watch(apiRepositoryProvider).fetchPlanner(week);

  final recipes = {for (final meal in meals) meal.recipe.id: meal.recipe};
  ref.read(remoteRecipesProvider.notifier).putAll(recipes.values);
  ref.read(plannerProvider.notifier).loadFromServer({
    for (final meal in meals) meal.day: {meal.slot: meal.recipe.id},
  });
  return meals;
});
