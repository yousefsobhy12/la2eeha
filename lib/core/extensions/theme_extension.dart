import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  bool get isLightMode => Theme.of(this).brightness == Brightness.light;

  Brightness get themeBrightness => Theme.of(this).brightness;

  Color get textPrimary => colorScheme.onSurface;

  Color get textSecondary => colorScheme.onSurfaceVariant;

  Color get textOnPrimary => colorScheme.onPrimary;

  Color get pageBackground => theme.scaffoldBackgroundColor;

  Color get surfaceColor => colorScheme.surface;

  Color get cardColor => theme.cardColor;

  Color get borderColor => colorScheme.outlineVariant;

  Color get dividerColor => theme.dividerColor;

  Color get iconColor => colorScheme.onSurfaceVariant;

  Color get hintColor => theme.hintColor;
}
