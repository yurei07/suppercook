import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suppercook/core/app_providers.dart';
import 'package:suppercook/data/api/api_repository.dart';
import 'package:suppercook/data/api/suppercook_api.dart';
import 'package:suppercook/data/models/ingredient.dart';
import 'package:suppercook/data/models/localized_text.dart';
import 'package:suppercook/data/providers/api_providers.dart';
import 'package:suppercook/data/providers/pantry_provider.dart';

class _StubRepository extends ApiRepository {
  _StubRepository() : super(SuppercookApi(Dio()));

  @override
  Future<List<Ingredient>> fetchPantry() async => [
        Ingredient(
          id: 'server_only_item',
          name: LocalizedText.same('Quinoa'),
          amount: 300,
          unit: 'g',
        ),
      ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pantrySync добавляет с сервера только недостающее (Live API)', () async {
    SharedPreferences.setMockInitialValues({'data_source': 'api'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        apiRepositoryProvider.overrideWithValue(_StubRepository()),
      ],
    );
    addTearDown(container.dispose);

    // Локально уже есть молоко; сервер должен добавить только quinoa.
    container.read(pantryProvider.notifier).add(
          Ingredient(
            id: 'milk',
            name: LocalizedText.same('Milk'),
            amount: 1,
            unit: 'l',
          ),
        );

    final added = await container.read(pantrySyncProvider.future);
    expect(added, 1);

    final ids = container.read(pantryIdsProvider);
    expect(ids, containsAll(<String>['milk', 'server_only_item']));
  });

  test('в demo режиме синк ничего не делает', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        apiRepositoryProvider.overrideWithValue(_StubRepository()),
      ],
    );
    addTearDown(container.dispose);

    final before = container.read(pantryProvider);
    final added = await container.read(pantrySyncProvider.future);
    expect(added, 0);
    // Кладовка осталась дефолтной, серверные позиции не прилетели
    expect(container.read(pantryProvider), same(before));
    expect(
      container.read(pantryIdsProvider),
      isNot(contains('server_only_item')),
    );
  });
}
