import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  static const _prefsKey = 'app_theme_mode';

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_prefsKey) == 'dark') emit(ThemeMode.dark);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(newMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      newMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}
