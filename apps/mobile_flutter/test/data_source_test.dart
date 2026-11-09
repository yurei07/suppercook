import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suppercook/core/app_providers.dart';
import 'package:suppercook/data/providers/data_source_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('data source selection survives a provider restart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final first = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(first.dispose);
    expect(first.read(dataSourceProvider), DataSource.demo);

    await first.read(dataSourceProvider.notifier).set(DataSource.api);

    final second = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(second.dispose);
    expect(second.read(dataSourceProvider), DataSource.api);
  });
}
