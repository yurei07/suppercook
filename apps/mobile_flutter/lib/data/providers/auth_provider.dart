import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_providers.dart';
import '../../core/preferences.dart';
import '../api/api_config.dart';
import '../api/api_models.dart';
import '../api/auth_repository.dart';

/// Залогиненный пользователь. null = гостевой режим (legacy x-user-id).
class AuthSession {
  final String token;
  final String userId;
  final String email;

  const AuthSession({
    required this.token,
    required this.userId,
    required this.email,
  });

  static AuthSession? fromPrefs(SharedPreferences prefs) {
    final token = readAuthToken(prefs);
    final userId = readAuthUserId(prefs);
    final email = readAuthEmail(prefs);
    if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
      return null;
    }
    return AuthSession(token: token, userId: userId, email: email ?? '');
  }
}

/// Отдельный Dio для входа/регистрации — без Bearer-заголовка.
/// Нельзя брать dioProvider: тот следит за authProvider, цикл.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );
  ref.onDispose(() => dio.close(force: true));
  return AuthRepository(dio: dio);
});

/// Держит сессию: восстанавливает из prefs при старте, пишет/чистит их
/// при входе и выходе. dioProvider следит за этим состоянием и подставляет
/// заголовок Authorization: Bearer.
class AuthNotifier extends Notifier<AuthSession?> {
  @override
  AuthSession? build() =>
      AuthSession.fromPrefs(ref.read(sharedPreferencesProvider));

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final session = await repository.register(
      email: email,
      password: password,
    );
    await _persist(session);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final repository = ref.read(authRepositoryProvider);
    final session = await repository.login(email: email, password: password);
    await _persist(session);
  }

  Future<void> signOut() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(authTokenKey);
    await prefs.remove(authUserIdKey);
    await prefs.remove(authEmailKey);
    state = null;
  }

  Future<void> _persist(ApiAuthSession apiSession) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(authTokenKey, apiSession.token);
    await prefs.setString(authUserIdKey, apiSession.user.id);
    await prefs.setString(authEmailKey, apiSession.user.email);
    state = AuthSession(
      token: apiSession.token,
      userId: apiSession.user.id,
      email: apiSession.user.email,
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthSession?>(
  AuthNotifier.new,
);
