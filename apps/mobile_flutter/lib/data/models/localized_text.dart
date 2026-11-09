import 'package:flutter/widgets.dart';

/// A tiny value object for content that comes from the backend (recipes,
/// ingredients, shopping items) and therefore cannot live in ARB files.
class LocalizedText {
  final String en;
  final String de;

  const LocalizedText(this.en, this.de);

  String resolve(Locale locale) => locale.languageCode == 'de' ? de : en;

  static LocalizedText same(String value) => LocalizedText(value, value);

  Map<String, dynamic> toJson() => {'en': en, 'de': de};

  factory LocalizedText.fromJson(Map<String, dynamic> json) => LocalizedText(
    json['en'] as String? ?? '',
    json['de'] as String? ?? '',
  );
}
