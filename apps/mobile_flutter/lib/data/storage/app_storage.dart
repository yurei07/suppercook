import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_providers.dart';
import '../models/ingredient.dart';
import '../models/shopping_item.dart';

/// Small JSON-backed persistence layer for the local-first MVP.
///
/// It deliberately hides SharedPreferences from the notifiers: when the NestJS
/// API is connected, these reads/writes become repository calls without
/// touching the screens.
class AppStorage {
  AppStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _pantryKey = 'pantry_items_v1';
  static const _shoppingKey = 'shopping_items_v1';
  static const _plannerKey = 'planner_v1';

  // ---------------------------------------------------------------------------
  // Pantry
  // ---------------------------------------------------------------------------
  List<Ingredient>? readPantry() {
    final raw = _prefs.getString(_pantryKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in decoded)
          Ingredient.fromJson(Map<String, dynamic>.from(item as Map)),
      ];
    } catch (_) {
      return null;
    }
  }

  void writePantry(List<Ingredient> items) {
    unawaited(
      _prefs.setString(
        _pantryKey,
        jsonEncode([for (final item in items) item.toJson()]),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shopping list
  // ---------------------------------------------------------------------------
  List<ShoppingItem>? readShopping() {
    final raw = _prefs.getString(_shoppingKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in decoded)
          ShoppingItem.fromJson(Map<String, dynamic>.from(item as Map)),
      ];
    } catch (_) {
      return null;
    }
  }

  void writeShopping(List<ShoppingItem> items) {
    unawaited(
      _prefs.setString(
        _shoppingKey,
        jsonEncode([for (final item in items) item.toJson()]),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Weekly planner
  // ---------------------------------------------------------------------------
  Map<int, Map<String, String>>? readPlan(DateTime weekStart) {
    final raw = _prefs.getString(_plannerKey);
    if (raw == null) return null;
    try {
      final root = jsonDecode(raw) as Map<String, dynamic>;
      if (root['weekStart'] != dateKey(weekStart)) return null;
      final plan = root['plan'] as Map<String, dynamic>;
      return {
        for (final entry in plan.entries)
          int.parse(entry.key): Map<String, String>.from(entry.value as Map),
      };
    } catch (_) {
      return null;
    }
  }

  void writePlan(DateTime weekStart, Map<int, Map<String, String>> plan) {
    final encodedPlan = {
      for (final entry in plan.entries) '${entry.key}': entry.value,
    };
    unawaited(
      _prefs.setString(
        _plannerKey,
        jsonEncode({
          'weekStart': dateKey(weekStart),
          'plan': encodedPlan,
        }),
      ),
    );
  }

  static String dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

final appStorageProvider = Provider<AppStorage>((ref) {
  return AppStorage(ref.watch(sharedPreferencesProvider));
});
