import 'ingredient.dart';
import 'localized_text.dart';

class ShoppingItem {
  final String id;
  final LocalizedText name;
  final IngredientCategory category;
  final bool checked;

  /// The original ingredient (if any) supplies amount + unit for display.
  final Ingredient? source;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    this.checked = false,
    this.source,
  });

  ShoppingItem copyWith({bool? checked}) => ShoppingItem(
    id: id,
    name: name,
    category: category,
    checked: checked ?? this.checked,
    source: source,
  );
}
