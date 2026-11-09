import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_storage.dart';

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
    final now = DateTime.now();
    _weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

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
  }

  void replaceAll(Map<int, Map<String, String>> plan) {
    state = {
      for (final entry in plan.entries)
        entry.key: Map<String, String>.from(entry.value),
    };
    _persist();
  }
}
