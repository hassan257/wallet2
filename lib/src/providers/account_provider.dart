import 'package:flutter/material.dart';

class AccountProvider with ChangeNotifier {
  String _cuenta = '';
  dynamic _saldo = 0;
  bool _isSaving = false;
  bool _menuDelete = false;
  String _id = '';

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  GlobalKey<FormState> get key => _key;

  // ignore: unnecessary_getters_setters
  dynamic get cuenta => _cuenta;

  set cuenta(dynamic newValue) {
    _cuenta = newValue;
  }

  dynamic get saldo => _saldo;

  set saldo(dynamic newValue) {
    _saldo = newValue;
    notifyListeners();
  }

  // ignore: unnecessary_getters_setters
  bool get isSaving => _isSaving;

  set isSaving(bool newValue) {
    _isSaving = newValue;
    notifyListeners();
  }

  // ignore: unnecessary_getters_setters
  bool get menuDelete => _menuDelete;

  set menuDelete(bool newValue) {
    _menuDelete = newValue;
    notifyListeners();
  }

  bool isValidForm() {
    return _key.currentState?.validate() ?? false;
  }

  // ignore: unnecessary_getters_setters
  String get id => _id;

  set id(String newValue) {
    _id = newValue;
    // notifyListeners();
  }

  reset() {
    _cuenta = '';
    _saldo = 0;
    _isSaving = false;
    _menuDelete = false;
    _id = '';
    notifyListeners();
  }
}
