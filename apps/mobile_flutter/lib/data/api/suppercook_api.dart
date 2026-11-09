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
}
