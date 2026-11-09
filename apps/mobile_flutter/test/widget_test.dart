import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suppercook/app/app.dart';
import 'package:suppercook/core/app_providers.dart';

void main() {
  testWidgets('language switches live without restarting the app', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const SuppercookApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose your language'), findsOneWidget);

    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();

    expect(find.text('Wähle deine Sprache'), findsOneWidget);
    expect(find.text('Weiter'), findsOneWidget);
    expect(prefs.getString('app_locale'), 'de');
  });
}
