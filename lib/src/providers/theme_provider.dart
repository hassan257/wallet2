import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _darkTheme = false;
  ThemeData _currentTheme = ThemeData.light();

  set darkTheme(bool value) {
    _darkTheme = value;
    if (value == true) {
      _currentTheme = ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
              primary: Colors.pinkAccent, secondary: Colors.white));
    } else {
      _currentTheme = ThemeData.light().copyWith(
        colorScheme: const ColorScheme.light(
            primary: Colors.pinkAccent, secondary: Colors.white),
      );
    }
    notifyListeners();
  }

  bool get darkTheme => _darkTheme;

  ThemeData get currentTheme => _currentTheme;
}
