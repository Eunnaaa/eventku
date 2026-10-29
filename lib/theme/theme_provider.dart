import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark;

  bool get isDark => _isDark;

  ThemeProvider({bool initialIsDark = false}) : _isDark = initialIsDark {
    _loadTheme();
  }

  void toggleTheme(bool value) async {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDark', value);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  void _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool('isDark');
      if (saved != null && saved != _isDark) {
        _isDark = saved;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }
}
