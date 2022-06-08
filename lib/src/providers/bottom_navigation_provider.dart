import 'package:flutter/material.dart';

class BottomNavigationProvider extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  set index(int newValue) {
    _index = newValue;
    notifyListeners();
  }

  bool _isLog = false;

  bool get isLog => _isLog;

  set isLog(bool newValue) {
    _isLog = newValue;
    // notifyListeners();
  }
}
