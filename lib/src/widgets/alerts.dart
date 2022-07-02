import 'package:flutter/material.dart';

class Alerts {
  confirmDialog({
    required BuildContext context,
    required String message,
    required Future<bool?> Function()? button1Function,
    required String button1Text,
    required Future<bool?> Function()? button2Function,
    required String button2Text,
  }) {
    Widget button1 = TextButton(
      child: Text(button1Text),
      onPressed: button1Function,
    );
    Widget button2 = TextButton(
      child: Text(button2Text),
      onPressed: button2Function,
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmar"),
      content: Text(message),
      actions: [button1, button2],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
