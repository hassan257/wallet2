import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSwitchTile extends StatefulWidget {
  final String opc1;
  final String opc2;
  final Function(bool)? function;
  const CustomSwitchTile({
    Key? key,
    required this.opc1,
    required this.opc2,
    this.function,
  }) : super(key: key);

  @override
  State<CustomSwitchTile> createState() => _CustomSwitchTileState();
}

class _CustomSwitchTileState extends State<CustomSwitchTile> {
  bool opc1Active = true;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'SwitchTile',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                opc1Active = !opc1Active;
              });
              if (widget.function != null) {
                widget.function!(opc1Active);
              }
            },
            child: Container(
              width: 100,
              height: 50,
              decoration: BoxDecoration(
                color: (opc1Active) ? Colors.pinkAccent : Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.opc1,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserratAlternates(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: (opc1Active) ? Colors.white : Colors.black45),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                opc1Active = !opc1Active;
              });
              if (widget.function != null) {
                widget.function!(opc1Active);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: (!opc1Active) ? Colors.pinkAccent : Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              width: 100,
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.opc2,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserratAlternates(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: (!opc1Active) ? Colors.white : Colors.black45),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
