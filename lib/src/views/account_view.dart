import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import '../helpers/ad_helper.dart';
import '../providers/providers.dart';
import '../services/navigation_service.dart';
import '../widgets/widgets.dart';

class AccountView extends StatelessWidget {
  final String? account;
  const AccountView({Key? key, this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AccountProvider accountProvider = Provider.of<AccountProvider>(context);
    return Stack(
      children: [
        if (accountProvider.id == '') const _Form() else const _StreamForm(),
        if (accountProvider.menuDelete) const _MenuDelete(),
        const _BotonRegresar(),
        if (accountProvider.id == '')
          const _BotonGuardar()
        else
          const _BotonModificar(),
      ],
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
                if (accountProvider.id != '') {
                  accountProvider.menuDelete = !accountProvider.menuDelete;
                }
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

class _BotonGuardar extends StatefulWidget {
  const _BotonGuardar({
    Key? key,
  }) : super(key: key);

  @override
  State<_BotonGuardar> createState() => _BotonGuardarState();
}

class _BotonGuardarState extends State<_BotonGuardar> {
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
    // print('Boton Guardar');
    _loadInterstitialAd();
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
                  // locator<NavigationService>().goBack('/moves');
                  if (_interstitialAd != null) {
                    _interstitialAd?.show();
                  } else {
                    locator<NavigationService>().goBack('/moves');
                  }
                }
              : null),
    );
  }
}

class _BotonModificar extends StatefulWidget {
  // final String id;
  const _BotonModificar({
    Key? key,
    // required this.id,
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
                  // Modificar cuenta
                  await FirebaseFirestore.instance
                      .doc('users/${currentUser!.uid}')
                      .collection('accounts')
                      .doc(accountProvider.id)
                      .update({'nombre': accountProvider.cuenta});
                  // Obtener los movimientos ligados a la cuenta
                  final QuerySnapshot<Map<String, dynamic>> movimientos =
                      await FirebaseFirestore.instance
                          .doc('users/${currentUser.uid}')
                          .collection('moves')
                          .where('cuenta_id', isEqualTo: accountProvider.id)
                          .get();
                  // Actualizar el nombre de la cuenta en los movimientos ya registrados
                  // ignore: avoid_function_literals_in_foreach_calls
                  movimientos.docs.forEach((element) async {
                    await FirebaseFirestore.instance
                        .doc('users/${currentUser.uid}')
                        .collection('moves')
                        .doc(element.id)
                        .update({'cuenta': accountProvider.cuenta});
                  });

                  accountProvider.isSaving = false;
                  // locator<NavigationService>().goBack('/moves');
                  if (_interstitialAd != null) {
                    _interstitialAd?.show();
                  } else {
                    locator<NavigationService>().goBack('/moves');
                  }
                }
              : null),
    );
  }
}

class _MenuDelete extends StatefulWidget {
  // final String id;
  const _MenuDelete({
    Key? key,
    // required this.id
  }) : super(key: key);

  @override
  State<_MenuDelete> createState() => _MenuDeleteState();
}

class _MenuDeleteState extends State<_MenuDelete> {
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
                message: '??Confirma eliminar la cuenta?',
                button1Function: !accountProvider.isSaving
                    ? () async {
                        accountProvider.menuDelete =
                            !accountProvider.menuDelete;
                        accountProvider.isSaving = true;
                        final currentUser = FirebaseAuth.instance.currentUser;
                        final id = accountProvider.id;
                        accountProvider.reset();
                        Navigator.pop(context);
                        // locator<NavigationService>().goBack('/moves');
                        if (_interstitialAd != null) {
                          _interstitialAd?.show();
                        } else {
                          locator<NavigationService>().goBack('/moves');
                        }
                        await FirebaseFirestore.instance
                            .doc('users/${currentUser!.uid}')
                            .collection('accounts')
                            .doc(id)
                            .delete();
                        locator<NavigationService>().goBack('/moves');
                        return null;
                      }
                    : null,
                button1Text: 'Si',
                button2Function: () async {
                  accountProvider.menuDelete = !accountProvider.menuDelete;
                  Navigator.pop(context);
                  return null;
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
