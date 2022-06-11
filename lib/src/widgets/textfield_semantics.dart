import 'package:flutter/material.dart';

class TextFieldSemantics extends StatelessWidget {
  const TextFieldSemantics({
    Key? key,
    required this.label, required this.hintText, this.labelColor, this.keyboardType, this.initialValue, this.onChanged, this.icon, this.iconFunction
  }) : super(key: key);

  final String label;
  final String hintText;
  final Color? labelColor;
  final TextInputType? keyboardType;
  final String? initialValue;
  final Function(String value)? onChanged;
  final IconData? icon;
  final Function()? iconFunction;

  @override
  Widget build(BuildContext context) {
    bool iconVisible = false;
    if(icon != null){
      iconVisible = true;
    }
    return Semantics(
      label: label,
      enabled: true,
      textField: true,
      child: Container(
        padding: const EdgeInsets.only(right: 10, left: 10, bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.fromBorderSide(BorderSide(
            color: (labelColor == null) ? Colors.grey : labelColor!,
          )),
        ),
        child: TextFormField(
          // inputFormatters: [
          //   // FilteringTextInputFormatter.allow(RegExp(r'^(([0-2]?[0-9])|([3]?[0-1]))|([\/])|(([0]?[1-9])|([1]?[0-2]))|([\/])|([0-9]{1,3})$')),
          //   FilteringTextInputFormatter.allow(RegExp(r'^(([0-2]?[0-9])|([3]?[0-1]))$')),
          // ],
          onChanged: onChanged,
          initialValue: initialValue,
          decoration: _inputDecoration(iconVisible: iconVisible, label: label, hintText: hintText, icon: icon, labelColor: labelColor, iconFunction: iconFunction),
          keyboardType: keyboardType,
          textCapitalization: TextCapitalization.sentences
        ),
      ),
    );
  }
}

 InputDecoration _inputDecoration({
   required bool iconVisible,
   required String label,
   required String hintText,
   IconData? icon,
   Color? labelColor,
   Function()? iconFunction
  }){
    if(iconVisible){
      return InputDecoration(
          icon: GestureDetector(
            onTap: iconFunction,
            child: Icon(icon, color: labelColor,)),
          label: Text(label, 
            style: TextStyle(
              color: labelColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          hintText: hintText,
      );
    }else{
      return InputDecoration(
        label: Text(label, 
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        hintText: hintText,
    );
    }
  
}