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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name.toJson(),
    'category': category.name,
    'checked': checked,
    'source': source?.toJson(),
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    final rawSource = json['source'];
    return ShoppingItem(
      id: json['id'] as String,
      name: LocalizedText.fromJson(
        Map<String, dynamic>.from(json['name'] as Map),
      ),
      category: IngredientCategory.values.firstWhere(
        (value) => value.name == json['category'],
        orElse: () => IngredientCategory.other,
      ),
      checked: json['checked'] as bool? ?? false,
      source: rawSource == null
          ? null
          : Ingredient.fromJson(Map<String, dynamic>.from(rawSource as Map)),
    );
  }
}
