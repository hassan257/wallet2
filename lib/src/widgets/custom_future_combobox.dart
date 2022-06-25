import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomFutureCombobox extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final future;
  final bool? collection;
  final Color? color;
  final String? label;
  dynamic value;
  final Function(dynamic) onChanged;
  final String? Function(dynamic)? validator;
  CustomFutureCombobox(
      {Key? key,
      required this.future,
      this.collection = false,
      this.color,
      this.label,
      this.value,
      required this.onChanged,
      this.validator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          if (!collection!) {
            final List<dynamic> elementos = snapshot.data!.get('tipos');
            // print(elementos);
            return _Combobox(
                elements: elementos,
                initialElement: elementos[0]['id'],
                color: color,
                label: label,
                value: value,
                onChanged: onChanged,
                validator: validator);
          } else {
            final List<QueryDocumentSnapshot> snapshotData =
                snapshot.data!.docs;
            List<Map<String, dynamic>> elementos = [];
            for (QueryDocumentSnapshot<Object?> element in snapshotData) {
              elementos
                  .add({'id': element.id, 'nombre': element.get('nombre')});
            }
            return _Combobox(
              elements: elementos,
              initialElement: elementos[0]['id'],
              color: color,
              label: label,
              value: value,
              onChanged: onChanged,
              validator: validator,
            );
          }
        } else {
          return const Center(
            child: Text('No se pudo cargar la información del catálogo'),
          );
        }
      },
    );
  }
}

// ignore: must_be_immutable
class _Combobox extends StatefulWidget {
  final List<dynamic> elements;
  final String? label;
  final Color? color;
  dynamic value;
  final Function(dynamic) onChanged;
  final String? Function(dynamic)? validator;
  dynamic initialElement;
  _Combobox(
      {Key? key,
      required this.elements,
      required this.initialElement,
      this.label,
      this.color,
      this.value,
      required this.onChanged,
      this.validator})
      : super(key: key);

  @override
  State<_Combobox> createState() => __ComboboxState();
}

class __ComboboxState extends State<_Combobox> {
  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<dynamic>> items = [];
    for (var element in widget.elements) {
      items.add(DropdownMenuItem<dynamic>(
        child: Text(element['nombre']),
        value: element['id'],
      ));
    }
    return Semantics(
      label: widget.label,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.fromBorderSide(BorderSide(
              color: (widget.color == null) ? Colors.grey : widget.color!,
            ))),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label ?? '',
              style:
                  TextStyle(color: widget.color, fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<dynamic>(
                isExpanded: true,
                // value: widget.initialElement,
                items: items,
                onChanged: (newValue) {
                  setState(() {
                    widget.initialElement = newValue!;
                    widget.value = newValue;
                    widget.onChanged(newValue);
                  });
                },
                validator: widget.validator
                // onChanged: widget.onChanged,
                ),
          ],
        ),
      ),
    );
  }
}
