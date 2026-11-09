import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ingredient.dart';

/// Set by the scan screen when the backend returns recognized ingredients.
/// `null` means "use the local demo result".
final scanResultProvider =
    NotifierProvider<ScanResultNotifier, List<Ingredient>?>(
      ScanResultNotifier.new,
    );

class ScanResultNotifier extends Notifier<List<Ingredient>?> {
  @override
  List<Ingredient>? build() => null;

  void set(List<Ingredient> items) => state = items;

  void clear() => state = null;
}
