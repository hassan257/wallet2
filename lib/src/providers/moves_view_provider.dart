import 'package:flutter/material.dart';

class MovesViewProvider with ChangeNotifier {
  int _index = 0;
  DateTime _currentDate = DateTime.now();
  int _counter = 0;
  String _selectedAccount = 'TODAS';
  double _saldo = 0;
  String _selectedCategoryGastos = 'TODAS';
  String _selectedCategoryIngresos = 'TODAS';

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

  int get counter => _counter;

  set counter(int value) {
    _counter = value;
    notifyListeners();
  }

  String get selectedAccount => _selectedAccount;

  set selectedAccount(String value) {
    _selectedAccount = value;
    notifyListeners();
  }

  // ignore: unnecessary_getters_setters
  double get saldo => _saldo;

  set saldo(double value) {
    _saldo = value;
    // notifyListeners();
  }

  String get selectedCategoryGastos => _selectedCategoryGastos;

  set selectedCategoryGastos(String value) {
    _selectedCategoryGastos = value;
    notifyListeners();
  }

  String get selectedCategoryIngresos => _selectedCategoryIngresos;

  set selectedCategoryIngresos(String value) {
    _selectedCategoryIngresos = value;
    notifyListeners();
  }
}
