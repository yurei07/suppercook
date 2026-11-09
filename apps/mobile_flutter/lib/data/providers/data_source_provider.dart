import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_providers.dart';
import '../../core/preferences.dart';

enum DataSource { demo, api }

final dataSourceProvider = NotifierProvider<DataSourceNotifier, DataSource>(
  DataSourceNotifier.new,
);

class DataSourceNotifier extends Notifier<DataSource> {
  @override
  DataSource build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(dataSourceKey);
    if (saved == DataSource.api.name) return DataSource.api;
    if (saved == DataSource.demo.name) return DataSource.demo;

    const fromEnv = String.fromEnvironment('SUPPERCOOK_DATA_SOURCE');
    return fromEnv == DataSource.api.name ? DataSource.api : DataSource.demo;
  }

  Future<void> set(DataSource source) async {
    state = source;
    await ref
        .read(sharedPreferencesProvider)
        .setString(dataSourceKey, source.name);
  }
}
