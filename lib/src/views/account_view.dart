import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import '../providers/providers.dart';
import '../services/navigation_service.dart';
import '../widgets/widgets.dart';

class AccountView extends StatelessWidget {
  final String? account;
  const AccountView({Key? key, this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AccountProvider accountProvider = Provider.of<AccountProvider>(context);

    // if (account != null) {
    //   accountProvider.id = account!;
    // }
    return SafeArea(
      child: Stack(
        children: [
          if (accountProvider.id == '') const _Form() else const _StreamForm(),
          if (accountProvider.menuDelete) const _MenuDelete(),
          const _BotonRegresar(),
          if (account == null)
            const _BotonGuardar()
          else
            const _BotonModificar(),
        ],
      ),
    );
  }
}

class _StreamForm extends StatelessWidget {
  // final String id;
  const _StreamForm({
    Key? key,
    // required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    AccountProvider accountProvider = Provider.of<AccountProvider>(context);
    if (accountProvider.id == '') return const _Form();
    // return StreamBuilder(
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('accounts')
            .doc(accountProvider.id)
            .get(),
        // stream: FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(currentUser!.uid)
        //     .collection('accounts')
        //     .doc(accountProvider.id)
        //     .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            // print(snapshot.data);
            if (snapshot.data!.exists) {
              return _Form(
                isUpdate: true,
                name: snapshot.data!.get('nombre'),
                saldo: snapshot.data!.get('saldo').toString(),
              );
            } else {
              return const _Form();
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}

class _Form extends StatelessWidget {
  final bool? isUpdate;
  final String? name;
  final String? saldo;
  const _Form({
    Key? key,
    this.isUpdate = false,
    this.name,
    this.saldo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print(name);
    AccountProvider accountProvider = Provider.of<AccountProvider>(context);
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.pinkAccent,
          leading: GestureDetector(
              onTap: () {
                accountProvider.menuDelete = !accountProvider.menuDelete;
                // print('nuevo valor ${accountProvider.menuDelete}');
              },
              child: const Icon(Icons.menu)),
        ),
        Expanded(child: Container()),
        Form(
          key: accountProvider.key,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                TextFieldSemantics(
                  label: 'Nombre de la Cuenta',
                  hintText: 'Nombre de la Cuenta',
                  labelColor: Colors.pinkAccent,
                  keyboardType: TextInputType.text,
                  initialValue: name,
                  onChanged: (value) => {accountProvider.cuenta = value},
                  validator: (value) {
                    if (value == '') {
                      return 'Debe indicar el nombre de la cuenta.';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFieldSemantics(
                  label: 'Saldo',
                  hintText: '\$',
                  labelColor: Colors.pinkAccent,
                  keyboardType: TextInputType.number,
                  onChanged: (newValue) => {accountProvider.saldo = newValue},
                  enabled: !isUpdate!,
                  initialValue: saldo,
                  validator: (value) {
                    if (value != null) {
                      if (value == '') {
                        value = '0.00';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
            child: Container(
                // color: Colors.green,
                )),
      ],
    );
  }
}

class _BotonRegresar extends StatelessWidget {
  const _BotonRegresar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AccountProvider accountProvider = Provider.of<AccountProvider>(context);
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
          accountProvider.isSaving = false;
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
    AccountProvider accountProvider = Provider.of<AccountProvider>(context);
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
          onPressed: !accountProvider.isSaving
              ? () async {
                  // print('aca');
                  if (!accountProvider.isValidForm()) return;
                  accountProvider.isSaving = true;
                  final currentUser = FirebaseAuth.instance.currentUser;
                  // Agregar movimiento
                  await FirebaseFirestore.instance
                      .doc('users/${currentUser!.uid}')
                      .collection('accounts')
                      .add({
                    'nombre': accountProvider.cuenta,
                    'saldo': accountProvider.saldo
                  });

                  accountProvider.isSaving = false;
                  locator<NavigationService>().goBack('/moves');
                }
              : null),
    );
  }
}

class _BotonModificar extends StatelessWidget {
  // final String id;
  const _BotonModificar({
    Key? key,
    // required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AccountProvider accountProvider = Provider.of<AccountProvider>(context);
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
          onPressed: !accountProvider.isSaving
              ? () async {
                  // print('aca');
                  if (!accountProvider.isValidForm()) return;
                  accountProvider.isSaving = true;
                  final currentUser = FirebaseAuth.instance.currentUser;
                  // Agregar movimiento
                  await FirebaseFirestore.instance
                      .doc('users/${currentUser!.uid}')
                      .collection('accounts')
                      .doc(accountProvider.id)
                      .update({'nombre': accountProvider.cuenta});

                  accountProvider.isSaving = false;
                  locator<NavigationService>().goBack('/moves');
                }
              : null),
    );
  }
}

class _MenuDelete extends StatelessWidget {
  // final String id;
  const _MenuDelete({
    Key? key,
    // required this.id
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AccountProvider accountProvider = Provider.of<AccountProvider>(context);
    return Positioned(
      top: 56,
      left: 0,
      child: Container(
        // height: 50,
        width: 130,
        color: Colors.pinkAccent,
        child: ListTile(
          onTap: () {
            Alerts().confirmDialog(
                context: context,
                message: '¿Confirma eliminar la cuenta?',
                button1Function: !accountProvider.isSaving
                    ? () async {
                        accountProvider.menuDelete =
                            !accountProvider.menuDelete;
                        accountProvider.isSaving = true;
                        final currentUser = FirebaseAuth.instance.currentUser;
                        final id = accountProvider.id;
                        accountProvider.reset();
                        Navigator.pop(context);
                        locator<NavigationService>().goBack('/moves');
                        await FirebaseFirestore.instance
                            .doc('users/${currentUser!.uid}')
                            .collection('accounts')
                            .doc(id)
                            .delete();
                      }
                    : null,
                button1Text: 'Si',
                button2Function: () async {
                  accountProvider.menuDelete = !accountProvider.menuDelete;
                  Navigator.pop(context);
                },
                button2Text: 'No');
          },
          // leading: const Icon(Icons.delete),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              Text(
                'Eliminar',
                style: GoogleFonts.montserratAlternates(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
