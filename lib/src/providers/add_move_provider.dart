import 'package:flutter/material.dart';

class AddMoveProvider with ChangeNotifier {
  bool _isGasto = true;

  bool get isGasto => _isGasto;

  set isGasto(bool newValue) {
    _isGasto = newValue;
    notifyListeners();
    // print(_isGasto);
  }
}
