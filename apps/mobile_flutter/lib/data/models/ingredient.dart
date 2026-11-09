import 'package:flutter/widgets.dart';

import 'localized_text.dart';

enum IngredientCategory { produce, dairy, pantry, other }

class Ingredient {
  final String id;
  final LocalizedText name;
  final double amount;
  final String unit;
  final IngredientCategory category;

  const Ingredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    this.category = IngredientCategory.other,
  });

  String unitLabel(Locale locale) {
    final de = locale.languageCode == 'de';
    return switch (unit) {
      'pcs' => de ? 'Stk.' : 'pcs',
      'clove' => de ? 'Zehe' : 'clove',
      'tbsp' => de ? 'EL' : 'tbsp',
      'tsp' => de ? 'TL' : 'tsp',
      'bunch' => de ? 'Bund' : 'bunch',
      'pinch' => de ? 'Prise' : 'pinch',
      'slice' => de ? 'Scheibe' : 'slice',
      _ => unit,
    };
  }

  String quantityLabel(Locale locale) {
    final rounded = amount == amount.roundToDouble();
    final value = rounded ? amount.toInt().toString() : amount.toStringAsFixed(1);
    return '$value ${unitLabel(locale)}';
  }
}
