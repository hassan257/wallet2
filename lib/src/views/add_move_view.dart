import 'package:flutter/material.dart';

import '../../locator.dart';
import '../services/navigation_service.dart';
import '../widgets/widgets.dart';

class AddMoveView extends StatelessWidget {
  const AddMoveView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Stack(
        children: [
          SizedBox(
            // color: Colors.red,
            height: size.height - 60,
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  SizedBox(
                    height: 20,
                  ),
                  CustomSwitchTile(opc1: 'Gasto', opc2: 'Ingreso')
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              backgroundColor: Colors.pinkAccent,
              heroTag: 'storeMove',
              child: const Icon(
                Icons.save,
                size: 40,
              ),
              onPressed: () {
                // TODO: Guardar movimiento
              },
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: FloatingActionButton(
              backgroundColor: Colors.pinkAccent,
              heroTag: 'backMoveView',
              child: const Icon(
                Icons.arrow_back,
                size: 40,
              ),
              onPressed: () {
                locator<NavigationService>().goBack('/moves');
              },
            ),
          )
        ],
      ),
    );
  }
}
