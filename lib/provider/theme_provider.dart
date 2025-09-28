import 'package:flutter/material.dart';
import 'package:prestige_pos/utils/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  final ThemeData _lightTheme = AppTheme.lightTheme;

  ThemeData get lightTheme => _lightTheme;

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
