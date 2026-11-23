import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_models.dart';

/// Почему вход/регистрация не сработали — маппится на локализованный текст в UI.
enum AuthError { invalidCredentials, emailTaken, network, other }

class AuthException implements Exception {
  final AuthError kind;
  final String message;

  const AuthException(this.kind, this.message);

  @override
  String toString() => 'AuthException($kind, $message)';
}

/// Регистрация и вход. Намеренно не зависит от dioProvider:
/// тот подставляет Bearer-токен из authProvider, а authProvider
/// вызывает этот репозиторий — свой Dio разрывает цикл.
class AuthRepository {
  AuthRepository({Dio? dio}) : _dio = dio ?? _buildDio();

  final Dio _dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
        // Ошибки 401/409 разбираем сами — DioException с response нужен.
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    return dio;
  }

  Future<ApiAuthSession> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {'email': email, 'password': password},
      );
      return ApiAuthSession.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<ApiAuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return ApiAuthSession.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  AuthException _map(DioException e) {
    final status = e.response?.statusCode;
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AuthException(
        AuthError.network,
        'Cannot reach the API at ${ApiConfig.baseUrl}',
      );
    }
    if (status == 401) {
      return const AuthException(
        AuthError.invalidCredentials,
        'Invalid email or password',
      );
    }
    if (status == 409) {
      return const AuthException(
        AuthError.emailTaken,
        'Email already registered',
      );
    }
    return AuthException(
      AuthError.other,
      'Auth failed (HTTP ${status ?? '??'})',
    );
  }
}
