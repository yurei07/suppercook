import 'package:flutter/material.dart';

/// Central color palette. Every screen must use these tokens instead of
/// hard-coded colors so the premium dark look stays consistent.
abstract final class AppColors {
  static const background = Color(0xFF0A0A0A);
  static const backgroundSoft = Color(0xFF101010);
  static const surface = Color(0xFF141414);
  static const surfaceElevated = Color(0xFF1C1C1C);
  static const surfaceHigh = Color(0xFF242424);
  static const border = Color(0xFF2A2A2A);
  static const borderSoft = Color(0xFF1F1F1F);

  static const accent = Color(0xFFF5A623);
  static const accentDeep = Color(0xFFE08A00);
  static const gold = Color(0xFFD9A441);
  static const accentSoft = Color(0x26F5A623);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0B0);
  static const textTertiary = Color(0xFF7A7A7A);
  static const textDisabled = Color(0xFF4F4F4F);

  static const success = Color(0xFF4CAF7D);
  static const warning = Color(0xFFE0A458);
  static const error = Color(0xFFE05252);

  static const overlayTop = Color(0x000A0A0A);
  static const overlayMiddle = Color(0xB30A0A0A);
  static const overlayBottom = Color(0xF20A0A0A);

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7B84B), accentDeep],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xE60A0A0A)],
    stops: [0.35, 1],
  );

  static const screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundSoft, background],
  );
}
