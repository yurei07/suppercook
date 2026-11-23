import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'api_models.dart';

class SuppercookApi {
  SuppercookApi(this._dio);

  final Dio _dio;

  Future<bool> ping() async {
    try {
      final response = await _dio.get<dynamic>('/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<ApiInventoryItem>> fetchInventory() async {
    final response = await _dio.get<List<dynamic>>('/inventory');
    final data = response.data ?? const <dynamic>[];
    return [
      for (final item in data)
        ApiInventoryItem.fromJson(Map<String, dynamic>.from(item as Map)),
    ];
  }

  Future<void> addInventoryItem({
    required String name,
    required double quantity,
    required String unit,
  }) async {
    await _dio.post<dynamic>(
      '/inventory',
      data: {'name': name, 'quantity': quantity, 'unit': unit},
    );
  }

  Future<List<ApiRecipe>> suggestRecipes({
    required String locale,
    required String diet,
    required List<String> allergens,
  }) async {
    final response = await _dio.post<List<dynamic>>(
      '/recipes/suggest',
      data: {
        'locale': locale,
        'diet': diet,
        if (allergens.isNotEmpty) 'allergens': allergens,
      },
    );
    final data = response.data ?? const <dynamic>[];
    return [
      for (final item in data)
        ApiRecipe.fromJson(Map<String, dynamic>.from(item as Map)),
    ];
  }

  Future<List<ApiRecognitionItem>> recognize({
    required Uint8List bytes,
    required String mimeType,
    required String locale,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/inventory/recognize',
      data: {
        'imageBase64': base64Encode(bytes),
        'mimeType': mimeType,
        'locale': locale,
      },
    );
    final data = response.data;
    final items = data?['items'];
    if (items is! List) return const [];
    return [
      for (final item in items)
        ApiRecognitionItem.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
    ];
  }

  Future<List<ApiShoppingItem>> fetchShopping() async {
    final response = await _dio.get<List<dynamic>>('/shopping');
    final data = response.data ?? const <dynamic>[];
    return [
      for (final item in data)
        ApiShoppingItem.fromJson(Map<String, dynamic>.from(item as Map)),
    ];
  }

  Future<void> addShoppingItem({
    required String name,
    required double quantity,
    required String unit,
  }) async {
    await _dio.post<dynamic>(
      '/shopping/items',
      data: {'name': name, 'quantity': quantity, 'unit': unit},
    );
  }

  Future<void> addMissingFromRecipe({
    required List<String> missingIngredients,
    String? recipeId,
  }) async {
    await _dio.post<dynamic>(
      '/shopping/from-recipe',
      data: {
        'missingIngredients': missingIngredients,
        'recipeId': ?recipeId,
      },
    );
  }

  Future<void> toggleShoppingItem(String id, bool checked) async {
    await _dio.patch<dynamic>('/shopping/items/$id', data: {'checked': checked});
  }

  Future<void> removeShoppingItem(String id) async {
    await _dio.delete<dynamic>('/shopping/items/$id');
  }

  Future<void> clearCheckedShopping() async {
    await _dio.delete<dynamic>('/shopping/checked');
  }

  // ---------------------------------------------------------------------------
  // Weekly planner
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> fetchPlanner(String week) async {
    final response = await _dio.get<List<dynamic>>(
      '/planner',
      queryParameters: {'week': week},
    );
    final data = response.data ?? const <dynamic>[];
    return [
      for (final item in data) Map<String, dynamic>.from(item as Map),
    ];
  }

  Future<void> upsertPlannerMeal({
    required String week,
    required int day,
    required String slot,
    required Map<String, dynamic> recipe,
  }) async {
    await _dio.put<dynamic>(
      '/planner/meals',
      data: {'week': week, 'day': day, 'slot': slot, 'recipe': recipe},
    );
  }

  Future<void> replaceWeekPlan({
    required String week,
    required List<Map<String, dynamic>> meals,
  }) async {
    await _dio.put<dynamic>('/planner', data: {'week': week, 'meals': meals});
  }

  Future<void> clearPlannerMeal({
    required String week,
    required int day,
    required String slot,
  }) async {
    await _dio.delete<dynamic>(
      '/planner/meals',
      queryParameters: {'week': week, 'day': day, 'slot': slot},
    );
  }
}
