import 'package:flutter/material.dart';

class MovesViewProvider with ChangeNotifier {
  int _index = 0;
  DateTime _currentDate = DateTime.now();

  int get index => _index;

  set index(int value) {
    _index = value;
    notifyListeners();
  }

  DateTime get currentDate => _currentDate;

  set currentDate(DateTime value) {
    _currentDate = value;
    notifyListeners();
  }
}
