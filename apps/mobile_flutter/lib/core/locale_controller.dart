import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';

const supportedAppLocales = [Locale('en'), Locale('de')];
const _localeKey = 'app_locale';

/// Holds the single source of truth for the UI language.
///
/// Changing [LocaleNotifier.setLocale] updates the `MaterialApp.router` locale,
/// which rebuilds the whole widget tree in place — no app restart required.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_localeKey);
    if (saved != null) {
      final locale = Locale(saved);
      if (supportedAppLocales.contains(locale)) return locale;
    }

    final system = WidgetsBinding.instance.platformDispatcher.locale;
    for (final locale in supportedAppLocales) {
      if (locale.languageCode == system.languageCode) return locale;
    }
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedAppLocales.contains(locale)) return;
    state = locale;
    await ref.read(sharedPreferencesProvider).setString(_localeKey, locale.languageCode);
  }
}
