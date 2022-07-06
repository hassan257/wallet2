import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:wallet2/src/providers/providers.dart';

import '../../locator.dart';
import '../helpers/ad_helper.dart';
import '../services/navigation_service.dart';
import '../widgets/widgets.dart';

class AddMoveView extends StatelessWidget {
  const AddMoveView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AddMoveProvider addMoveProvider = Provider.of<AddMoveProvider>(context);
    return SafeArea(
      child: Stack(
        children: [
          const _Form(),
          if (addMoveProvider.id == '')
            const _BotonGuardar()
          else
            const _BotonModificar(),
          const _BotonRegresar()
        ],
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

    final size = MediaQuery.of(context).size;

    final Timestamp fechaTimestamp = addMoveProvider.fecha;
    final DateTime fechaDateTime = fechaTimestamp.toDate();
    addMoveProvider.fechaString =
        "${fechaDateTime.day}/${fechaDateTime.month}/${fechaDateTime.year}";

    return SizedBox(
      height: size.height - 60,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: addMoveProvider.key,
            child: Column(
              children: [
                CustomSwitchTile(
                  opc1: 'Gasto',
                  opc2: 'Ingreso',
                  function: (value) {
                    addMoveProvider.isGasto = value;
                    if (addMoveProvider.isGasto) {
                      addMoveProvider.conceptoIngreso = null;
                    } else {
                      addMoveProvider.conceptoGasto = null;
                    }
                  },
                  initialValue: addMoveProvider.isGasto,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomStreamCombobox(
                  menuItemChild: 'nombre',
                  menuItemValue: 'id',
                  // future: FirebaseFirestore.instance
                  //     .collection('users')
                  //     .doc(currentUser!.uid)
                  //     .collection('accounts')
                  //     .get(),
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser!.uid)
                      .collection('accounts')
                      .snapshots(),
                  label: 'Cuenta',
                  color: Colors.pinkAccent,
                  collection: true,
                  value: addMoveProvider.cuenta == ''
                      ? null
                      : addMoveProvider.cuenta,
                  onChanged: (value) => {addMoveProvider.cuenta = value},
                  validator: (value) {
                    // print(value);
                    if (value == '' || value == null) {
                      return 'Debe seleccionar una cuenta valida';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                addMoveProvider.isGasto
                    ? CustomStreamCombobox(
                        // future: FirebaseFirestore.instance
                        //     .collection('catalogs')
                        //     .doc('tipoConcepto')
                        //     .collection('movimientosGasto')
                        //     .get(),
                        stream: FirebaseFirestore.instance
                            .collection('catalogs')
                            .doc('tipoConcepto')
                            .collection('movimientosGasto')
                            .snapshots(),
                        label: 'Categoria',
                        collection: true,
                        value: addMoveProvider.conceptoGasto == ''
                            ? null
                            : addMoveProvider.conceptoGasto,
                        color: Colors.pinkAccent,
                        onChanged: (value) =>
                            {addMoveProvider.conceptoGasto = value},
                        validator: (value) {
                          if (value == '' || value == null) {
                            return 'Debe seleccionar una categoria valida';
                          }
                          return null;
                        },
                        menuItemChild: 'nombre',
                        menuItemValue: 'id',
                      )
                    : CustomStreamCombobox(
                        // future: FirebaseFirestore.instance
                        //     .collection('catalogs')
                        //     .doc('tipoConcepto')
                        //     .collection('movimientosIngreso')
                        //     .get(),
                        stream: FirebaseFirestore.instance
                            .collection('catalogs')
                            .doc('tipoConcepto')
                            .collection('movimientosIngreso')
                            .snapshots(),
                        label: 'Categoria',
                        collection: true,
                        color: Colors.pinkAccent,
                        value: addMoveProvider.conceptoIngreso == ''
                            ? null
                            : addMoveProvider.conceptoIngreso,
                        onChanged: (value) {
                          // print(value);
                          addMoveProvider.conceptoIngreso = value;
                        },
                        menuItemChild: 'nombre',
                        menuItemValue: 'id',
                        validator: (value) {
                          if (value == '' || value == null) {
                            return 'Debe seleccionar una categoria valida';
                          }
                          return null;
                        },
                      ),
                const SizedBox(
                  height: 20,
                ),
                TextFieldSemantics(
                  label: 'Importe',
                  hintText: '\$',
                  labelColor: Colors.pinkAccent,
                  keyboardType: TextInputType.number,
                  onChanged: (newValue) => {addMoveProvider.importe = newValue},
                  validator: (value) {
                    if (value != null) {
                      if (value == '') {
                        value = '0';
                      }
                      if (double.parse(value) <= 0) {
                        return 'El importe debe ser mayor a cero';
                      }
                    }
                    return null;
                  },
                  initialValue: addMoveProvider.importe,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFieldSemantics(
                  label: 'Nombre del Movimiento',
                  hintText: 'Nombre del Movimiento',
                  labelColor: Colors.pinkAccent,
                  keyboardType: TextInputType.text,
                  onChanged: (value) => {addMoveProvider.movimiento = value},
                  validator: (value) {
                    if (value == '') {
                      return 'Debe indicar el nombre del movimiento.';
                    }
                    return null;
                  },
                  initialValue: addMoveProvider.movimiento,
                ),
                const SizedBox(
                  height: 20,
                ),
                _CustomDateField(
                    fechaString: addMoveProvider.fechaString,
                    function: () async {
                      final DateTime? selected = await showDatePicker(
                        context: context,
                        initialDate: addMoveProvider.fecha.toDate(),
                        firstDate: DateTime(2010),
                        lastDate: DateTime(2025),
                      );
                      if (selected != null) {
                        addMoveProvider.fecha = Timestamp.fromDate(selected);
                        addMoveProvider.fechaString =
                            '${selected.day}/${selected.month}/${selected.year}';
                      }
                    }),
                const SizedBox(
                  height: 20,
                ),
                TextFieldSemantics(
                  label: 'Descripción',
                  hintText: 'Descripción',
                  labelColor: Colors.pinkAccent,
                  keyboardType: TextInputType.text,
                  onChanged: (value) => {addMoveProvider.descripcion = value},
                  initialValue: addMoveProvider.descripcion,
                ),
                const SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomDateField extends StatelessWidget {
  final String fechaString;
  final void Function()? function;
  const _CustomDateField({required this.fechaString, required this.function});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 10, left: 10, bottom: 15, top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: const Border.fromBorderSide(BorderSide(
          color: Colors.pinkAccent,
        )),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fecha del Movimiento',
            style: GoogleFonts.montserratAlternates(
                color: Colors.pinkAccent, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: function,
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 40,
                  color: Colors.pinkAccent,
                ),
                const SizedBox(width: 20),
                Text(
                  fechaString,
                  style: GoogleFonts.montserratAlternates(
                      // color: Colors.pinkAccent
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
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
    AddMoveProvider addMoveProvider = Provider.of<AddMoveProvider>(context);
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
          addMoveProvider.isSaving = false;
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
    AddMoveProvider addMoveProvider = Provider.of<AddMoveProvider>(context);
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
        onPressed: addMoveProvider.isSaving
            ? null
            : () async {
                if (!addMoveProvider.isValidForm()) return;
                addMoveProvider.isSaving = true;
                final currentUser = FirebaseAuth.instance.currentUser;
                final cuentaSplit =
                    addMoveProvider.cuenta.toString().split('\$');
                final categoriaSplit = addMoveProvider.isGasto
                    ? addMoveProvider.conceptoGasto.toString().split('\$')
                    : addMoveProvider.conceptoIngreso.toString().split('\$');
                // Parsear fecha
                // final fecha = addMoveProvider.fecha.toString().split('/');
                // final DateTime fechaDT = DateTime(int.parse(fecha[2]),
                //     int.parse(fecha[1]), int.parse(fecha[0]));
                // final Timestamp fechaT = Timestamp.fromDate(fechaDT);
                // Agregar movimiento
                await FirebaseFirestore.instance
                    .doc('users/${currentUser!.uid}')
                    .collection('moves')
                    .add({
                  'tipo': addMoveProvider.isGasto ? 'GASTO' : 'INGRESO',
                  // 'cuenta': addMoveProvider.cuenta,
                  'cuenta': cuentaSplit[1],
                  'cuenta_id': cuentaSplit[0],
                  'categoria': categoriaSplit[1],
                  'categoria_id': categoriaSplit[0],
                  'cantidad': addMoveProvider.importe,
                  'nombre': addMoveProvider.movimiento,
                  'fecha': addMoveProvider.fecha,
                  'descripcion': addMoveProvider.descripcion
                });
                // Obtener datos de la cuenta
                final DocumentSnapshot<Map<String, dynamic>> datosCuenta =
                    await FirebaseFirestore.instance
                        .doc('users/${currentUser.uid}')
                        .collection('accounts')
                        .doc(cuentaSplit[0])
                        .get();
                // print(datosCuenta.data());
                // Actualizar el saldo en la cuenta
                final saldoFinal = addMoveProvider.isGasto
                    ? double.parse("${datosCuenta.get('saldo')}") -
                        double.parse("${addMoveProvider.importe}")
                    : double.parse("${datosCuenta.get('saldo')}") +
                        double.parse("${addMoveProvider.importe}");
                await FirebaseFirestore.instance
                    .doc('users/${currentUser.uid}')
                    .collection('accounts')
                    .doc(cuentaSplit[0])
                    .update({'saldo': saldoFinal});
                addMoveProvider.isSaving = false;
                locator<NavigationService>().goBack('/moves');
              },
      ),
    );
  }
}

class _BotonModificar extends StatefulWidget {
  const _BotonModificar({
    Key? key,
  }) : super(key: key);

  @override
  State<_BotonModificar> createState() => _BotonModificarState();
}

class _BotonModificarState extends State<_BotonModificar> {
  InterstitialAd? _interstitialAd;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              // _moveToHome();
              locator<NavigationService>().goBack('/moves');
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          // ignore: avoid_print
          print('Failed to load an interstitial ad: ${err.message}');
          // _isInterstitialAdReady = false;
        },
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _loadInterstitialAd();
    AddMoveProvider addMoveProvider = Provider.of<AddMoveProvider>(context);
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
        onPressed: addMoveProvider.isSaving
            ? null
            : () async {
                if (!addMoveProvider.isValidForm()) return;
                addMoveProvider.isSaving = true;
                final currentUser = FirebaseAuth.instance.currentUser;
                final cuentaSplit =
                    addMoveProvider.cuenta.toString().split('\$');
                final categoriaSplit = addMoveProvider.isGasto
                    ? addMoveProvider.conceptoGasto.toString().split('\$')
                    : addMoveProvider.conceptoIngreso.toString().split('\$');
                // Parsear fecha
                // final fecha = addMoveProvider.fecha.toString().split('/');
                // final DateTime fechaDT = DateTime(int.parse(fecha[2]),
                //     int.parse(fecha[1]), int.parse(fecha[0]));
                // final Timestamp fechaT = Timestamp.fromDate(fechaDT);
                // Actualizar movimiento
                await FirebaseFirestore.instance
                    .doc('users/${currentUser!.uid}')
                    .collection('moves')
                    .doc(addMoveProvider.id)
                    .update({
                  'tipo': addMoveProvider.isGasto ? 'GASTO' : 'INGRESO',
                  // 'cuenta': addMoveProvider.cuenta,
                  'cuenta': cuentaSplit[1],
                  'cuenta_id': cuentaSplit[0],
                  'categoria': categoriaSplit[1],
                  'categoria_id': categoriaSplit[0],
                  'cantidad': addMoveProvider.importe,
                  'nombre': addMoveProvider.movimiento,
                  'fecha': addMoveProvider.fecha,
                  'descripcion': addMoveProvider.descripcion
                });
                // Obtener datos de la cuenta
                final DocumentSnapshot<Map<String, dynamic>> datosCuenta =
                    await FirebaseFirestore.instance
                        .doc('users/${currentUser.uid}')
                        .collection('accounts')
                        .doc(cuentaSplit[0])
                        .get();
                // print(datosCuenta.data());
                // Actualizar el saldo en la cuenta
                double saldoFinal = addMoveProvider.isGasto
                    ? double.parse("${datosCuenta.get('saldo')}") -
                        double.parse("${addMoveProvider.importe}")
                    : double.parse("${datosCuenta.get('saldo')}") +
                        double.parse("${addMoveProvider.importe}");
                //  Agregar o restar el saldo anterior al saldo final
                if (addMoveProvider.tipoMovimientoAnterior == 'GASTO') {
                  saldoFinal += addMoveProvider.saldoAnterior;
                } else {
                  saldoFinal -= addMoveProvider.saldoAnterior;
                }
                await FirebaseFirestore.instance
                    .doc('users/${currentUser.uid}')
                    .collection('accounts')
                    .doc(cuentaSplit[0])
                    .update({'saldo': saldoFinal});
                addMoveProvider.isSaving = false;
                // locator<NavigationService>().goBack('/moves');
                if (_interstitialAd != null) {
                  _interstitialAd?.show();
                } else {
                  locator<NavigationService>().goBack('/moves');
                }
              },
      ),
    );
  }
}
