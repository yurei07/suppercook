import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in `main()` once SharedPreferences is loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

/// Dev-only deep link: run the Linux binary with `--route=/recipe/salmon_bowl`
/// to boot directly into a screen for visual QA.
final initialRouteOverrideProvider = Provider<String?>((ref) => null);
