import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DateFieldSemantics extends StatefulWidget {
  const DateFieldSemantics(
      {Key? key,
      required this.label,
      required this.hintText,
      this.labelColor,
      this.keyboardType,
      this.initialValue,
      required this.onChanged,
      this.icon,
      this.iconFunction,
      this.validator})
      : super(key: key);

  final String label;
  final String hintText;
  final Color? labelColor;
  final TextInputType? keyboardType;
  final String? initialValue;
  final Function(String value) onChanged;
  final IconData? icon;
  final Function()? iconFunction;
  final String? Function(String?)? validator;

  @override
  State<DateFieldSemantics> createState() => _DateFieldSemanticsState();
}

class _DateFieldSemanticsState extends State<DateFieldSemantics> {
  // DateTime selectedDate = DateTime.now();
  late DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    bool iconVisible = false;
    if (widget.icon != null) {
      iconVisible = true;
    }
    String value = '';
    if (widget.initialValue != null) {
      if (widget.initialValue != '') {
        value = widget.initialValue!;
      }
    }
    // setState(() {
    //   widget.onChanged(value);
    // });
    // print(value);
    return Semantics(
      label: widget.label,
      enabled: true,
      textField: true,
      child: Container(
        padding: const EdgeInsets.only(right: 10, left: 10, bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.fromBorderSide(BorderSide(
            color:
                (widget.labelColor == null) ? Colors.grey : widget.labelColor!,
          )),
        ),
        child: TextFormField(
            style: GoogleFonts.montserratAlternates(),
            controller: TextEditingController(text: value),
            onChanged: widget.onChanged,
            validator: widget.validator,
            onTap: () async {
              final DateTime? selected = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2010),
                lastDate: DateTime(2025),
              );
              if (selected != null && selected != selectedDate) {
                setState(() {
                  selectedDate = selected;
                  value =
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
                  widget.onChanged(value);
                  // print(value);
                });
              }
            },
            // initialValue: widget.initialValue,
            decoration: _inputDecoration(
              iconVisible: iconVisible,
              label: widget.label,
              hintText: widget.hintText,
              icon: widget.icon,
              labelColor: widget.labelColor,
              iconFunction: () async {
                final DateTime? selected = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2010),
                  lastDate: DateTime(2025),
                );
                if (selected != null && selected != selectedDate) {
                  setState(() {
                    selectedDate = selected;
                    value =
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
                    widget.onChanged(value);
                  });
                }
              },
            ),
            keyboardType: widget.keyboardType,
            textCapitalization: TextCapitalization.sentences),
      ),
    );
  }
}

InputDecoration _inputDecoration(
    {required bool iconVisible,
    required String label,
    required String hintText,
    IconData? icon,
    Color? labelColor,
    Function()? iconFunction}) {
  if (iconVisible) {
    return InputDecoration(
        icon: GestureDetector(
            onTap: iconFunction,
            child: Icon(
              icon,
              color: labelColor,
            )),
        label: Text(
          label,
          style: GoogleFonts.montserratAlternates(
            color: labelColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        hintText: hintText,
        hintStyle: GoogleFonts.montserratAlternates());
  } else {
    return InputDecoration(
        label: Text(
          label,
          style: GoogleFonts.montserratAlternates(
            color: labelColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        hintText: hintText,
        hintStyle: GoogleFonts.montserratAlternates());
  }
}
