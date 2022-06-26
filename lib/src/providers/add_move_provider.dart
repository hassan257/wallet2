import 'package:flutter/material.dart';

class AddMoveProvider with ChangeNotifier {
  bool _isGasto = true;
  dynamic _cuenta = '';
  dynamic _conceptoIngreso = '';
  dynamic _conceptoGasto = '';
  dynamic _importe = '';
  dynamic _movimiento = '';
  dynamic _fecha = '';
  dynamic _descripcion = '';
  bool _isSaving = false;

  reset() {
    _isGasto = true;
    _cuenta = '';
    _conceptoIngreso = '';
    _conceptoGasto = '';
    _importe = '';
    _movimiento = '';
    _fecha = '';
    _descripcion = '';
    _isSaving = false;
    notifyListeners();
  }

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  GlobalKey<FormState> get key => _key;

  bool get isGasto => _isGasto;

  set isGasto(bool newValue) {
    _isGasto = newValue;
    notifyListeners();
  }

  // ignore: unnecessary_getters_setters
  dynamic get cuenta => _cuenta;

  set cuenta(dynamic newValue) {
    _cuenta = newValue;
  }

  // ignore: unnecessary_getters_setters
  dynamic get conceptoIngreso => _conceptoIngreso;

  set conceptoIngreso(dynamic newValue) {
    _conceptoIngreso = newValue;
  }

  // ignore: unnecessary_getters_setters
  dynamic get conceptoGasto => _conceptoGasto;

  set conceptoGasto(dynamic newValue) {
    _conceptoGasto = newValue;
  }

  dynamic get importe => _importe;

  set importe(dynamic newValue) {
    _importe = newValue;
    notifyListeners();
  }

  dynamic get movimiento => _movimiento;

  set movimiento(dynamic newValue) {
    _movimiento = newValue;
    notifyListeners();
  }

  // ignore: unnecessary_getters_setters
  dynamic get fecha => _fecha;

  set fecha(dynamic newValue) {
    _fecha = newValue;
    // notifyListeners();
  }

  // ignore: unnecessary_getters_setters
  dynamic get descripcion => _descripcion;

  set descripcion(dynamic newValue) {
    _descripcion = newValue;
    notifyListeners();
  }

  // ignore: unnecessary_getters_setters
  bool get isSaving => _isSaving;

  set isSaving(bool newValue) {
    _isSaving = newValue;
    notifyListeners();
  }

  bool isValidForm() {
    return _key.currentState?.validate() ?? false;
  }
}
