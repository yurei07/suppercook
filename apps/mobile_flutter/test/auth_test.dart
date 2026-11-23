import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suppercook/core/app_providers.dart';
import 'package:suppercook/core/preferences.dart';
import 'package:suppercook/data/api/auth_repository.dart';
import 'package:suppercook/data/providers/api_providers.dart';
import 'package:suppercook/data/providers/auth_provider.dart';

/// Фейковый HTTP: /auth/register и /auth/login без сети.
class _FakeAuthAdapter implements HttpClientAdapter {
  int registerCalls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    final body = options.data is Map
        ? Map<String, dynamic>.from(options.data as Map)
        : <String, dynamic>{};
    if (path == '/auth/register') {
      registerCalls++;
      // Второй раз с тем же email — 409 (email занят)
      if (registerCalls > 1 && body['email'] == 'new@test.io') {
        return _response({'message': 'Email already registered'}, 409);
      }
      return _session(body['email'] as String? ?? '');
    }
    if (path == '/auth/login') {
      if (body['password'] == 'password-1') {
        return _session(body['email'] as String? ?? '');
      }
      return _response({'message': 'Invalid email or password'}, 401);
    }
    return _response({'message': 'Not found'}, 404);
  }

  ResponseBody _session(String email) => _response({
        'token': 'jwt-token-1',
        'user': {'id': 'user-1', 'email': email},
      }, 201);

  ResponseBody _response(Map<String, dynamic> json, int status) =>
      ResponseBody.fromString(
        jsonEncode(json),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
}

ProviderContainer _container(SharedPreferences prefs) {
  final adapter = _FakeAuthAdapter();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      authRepositoryProvider.overrideWith(
        (ref) => AuthRepository(
          dio: Dio(
            BaseOptions(baseUrl: 'http://test.local'),
          )..httpClientAdapter = adapter,
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthSession', () {
    test('восстанавливается из prefs, если токен и userId на месте', () async {
      SharedPreferences.setMockInitialValues({
        authTokenKey: 'token-1',
        authUserIdKey: 'user-1',
        authEmailKey: 'a@b.io',
      });
      final prefs = await SharedPreferences.getInstance();
      final session = AuthSession.fromPrefs(prefs);
      expect(session, isNotNull);
      expect(session!.token, 'token-1');
      expect(session.userId, 'user-1');
      expect(session.email, 'a@b.io');
    });

    test('null без токена (гостевой режим)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(AuthSession.fromPrefs(prefs), isNull);
    });
  });

  group('AuthNotifier', () {
    test('register пишет сессию в состояние и prefs', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = _container(prefs);

      await container
          .read(authProvider.notifier)
          .register(email: 'new@test.io', password: 'password-1');

      final state = container.read(authProvider);
      expect(state, isNotNull);
      expect(state!.email, 'new@test.io');
      expect(prefs.getString(authTokenKey), 'jwt-token-1');
      expect(prefs.getString(authUserIdKey), 'user-1');
    });

    test('signOut чистит состояние и prefs', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = _container(prefs);

      await container
          .read(authProvider.notifier)
          .signIn(email: 'a@b.io', password: 'password-1');
      expect(container.read(authProvider), isNotNull);

      await container.read(authProvider.notifier).signOut();
      expect(container.read(authProvider), isNull);
      expect(prefs.getString(authTokenKey), isNull);
    });

    test('неверный пароль → AuthException.invalidCredentials', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = _container(prefs);

      await expectLater(
        container
            .read(authProvider.notifier)
            .signIn(email: 'a@b.io', password: 'wrong-password'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.kind,
            'kind',
            AuthError.invalidCredentials,
          ),
        ),
      );
    });

    test('повторная регистрация → AuthException.emailTaken', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = _container(prefs);

      await container
          .read(authProvider.notifier)
          .register(email: 'new@test.io', password: 'password-1');
      await container.read(authProvider.notifier).signOut();
      await expectLater(
        container
            .read(authProvider.notifier)
            .register(email: 'new@test.io', password: 'password-1'),
        throwsA(
          isA<AuthException>()
              .having((e) => e.kind, 'kind', AuthError.emailTaken),
        ),
      );
    });
  });

  group('dioProvider', () {
    test('гость шлёт legacy x-user-id, залогиненный — Bearer', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = _container(prefs);

      final guestDio = container.read(dioProvider);
      expect(guestDio.options.headers.containsKey('x-user-id'), isTrue);
      expect(guestDio.options.headers.containsKey('Authorization'), isFalse);

      await container
          .read(authProvider.notifier)
          .signIn(email: 'a@b.io', password: 'password-1');

      final authedDio = container.read(dioProvider);
      expect(authedDio.options.headers['Authorization'], 'Bearer jwt-token-1');
      expect(authedDio.options.headers.containsKey('x-user-id'), isFalse);
    });
  });
}
