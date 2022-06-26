import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import '../providers/providers.dart';
import '../services/navigation_service.dart';
import '../widgets/cuentas.dart';

class MovesView extends StatelessWidget {
  const MovesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    AddMoveProvider addMoveProvider = Provider.of<AddMoveProvider>(context);
    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: const [
              Cuentas(),
            ],
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              backgroundColor: Colors.pinkAccent,
              heroTag: 'addMove',
              child: const Icon(
                Icons.add_circle,
                size: 40,
              ),
              onPressed: () {
                addMoveProvider.reset();
                locator<NavigationService>().navigateTo('/addmove');
              },
            ),
          )
        ],
      ),
    );
  }
}
