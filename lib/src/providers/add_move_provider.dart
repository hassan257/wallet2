import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMoveProvider with ChangeNotifier {
  bool _isGasto = true;
  dynamic _cuenta = '';
  dynamic _conceptoIngreso = '';
  dynamic _conceptoGasto = '';
  dynamic _importe = '';
  dynamic _movimiento = '';
  Timestamp _fecha = Timestamp.now();
  String _fechaString = '';
  dynamic _descripcion = '';
  bool _isSaving = false;
  String _id = '';

  // Validos solo para la modificación
  double _saldoAnterior = 0;
  String _tipoMovimientoAnterior = '';

  reset() {
    _isGasto = true;
    _cuenta = '';
    _conceptoIngreso = '';
    _conceptoGasto = '';
    _importe = '';
    _movimiento = '';
    _fecha = Timestamp.now();
    _descripcion = '';
    _isSaving = false;
    _id = '';
    _saldoAnterior = 0;
    _fechaString = '';
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
  Timestamp get fecha => _fecha;

  set fecha(Timestamp newValue) {
    _fecha = newValue;
    notifyListeners();
  }

  // ignore: unnecessary_getters_setters
  String get fechaString => _fechaString;

  set fechaString(String newValue) {
    _fechaString = newValue;
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

  // ignore: unnecessary_getters_setters
  String get id => _id;

  set id(String newValue) {
    _id = newValue;
    // notifyListeners();
  }

  // ignore: unnecessary_getters_setters
  double get saldoAnterior => _saldoAnterior;

  set saldoAnterior(double valor) {
    _saldoAnterior = valor;
  }

  // ignore: unnecessary_getters_setters
  String get tipoMovimientoAnterior => _tipoMovimientoAnterior;

  set tipoMovimientoAnterior(String valor) {
    _tipoMovimientoAnterior = valor;
  }
}
