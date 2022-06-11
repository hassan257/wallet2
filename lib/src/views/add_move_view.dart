import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet2/src/providers/providers.dart';

import '../../locator.dart';
import '../services/navigation_service.dart';
import '../widgets/widgets.dart';

class AddMoveView extends StatelessWidget {
  const AddMoveView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: const [_Form(), _BotonGuardar(), _BotonRegresar()],
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AddMoveProvider addMoveProvider = Provider.of<AddMoveProvider>(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    // if (currentUser != null) {
    //   print(currentUser.uid);
    // }
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height - 60,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomSwitchTile(
                opc1: 'Gasto',
                opc2: 'Ingreso',
                function: (value) => {addMoveProvider.isGasto = value},
              ),
              const SizedBox(
                height: 20,
              ),
              CustomFutureCombobox(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.uid)
                    .collection('accounts')
                    .get(),
                label: 'Cuenta',
                color: Colors.pinkAccent,
                collection: true,
              ),
              const SizedBox(
                height: 20,
              ),
              CustomFutureCombobox(
                future: FirebaseFirestore.instance
                    .collection('catalogs')
                    .doc('tipoConcepto')
                    .get(),
                label: 'Categoria',
                color: Colors.pinkAccent,
              ),
              const SizedBox(
                height: 20,
              ),
              const TextFieldSemantics(
                label: 'Importe',
                hintText: '\$',
                labelColor: Colors.pinkAccent,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 20,
              ),
              const TextFieldSemantics(
                label: 'Nombre del Movimiento',
                hintText: 'Nombre del Movimiento',
                labelColor: Colors.pinkAccent,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 20,
              ),
              const DateFieldSemantics(
                label: 'Fecha del Movimiento',
                hintText: 'Fecha del Movimiento',
                labelColor: Colors.pinkAccent,
                keyboardType: TextInputType.datetime,
                icon: Icons.date_range,
              ),
              const SizedBox(
                height: 20,
              ),
              const TextFieldSemantics(
                label: 'Descripción',
                hintText: 'Descripción',
                labelColor: Colors.pinkAccent,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonRegresar extends StatelessWidget {
  const _BotonRegresar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
    );
  }
}

class _BotonGuardar extends StatelessWidget {
  const _BotonGuardar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
    );
  }
}
