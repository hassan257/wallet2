import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import '../providers/providers.dart';
import '../services/navigation_service.dart';

class Cuentas extends StatelessWidget {
  const Cuentas({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    AccountProvider accountProvider = Provider.of<AccountProvider>(context);
    return SizedBox(
      // color: Colors.red,
      height: 150,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('accounts')
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            final List<QueryDocumentSnapshot<Map<String, dynamic>>>
                cuentasFirebase = snapshot.data!.docs;
            List<Map<String, dynamic>> cuentas = [];
            for (var cuenta in cuentasFirebase) {
              {
                cuentas.add({
                  'id': cuenta.id,
                  'nombre': cuenta.get('nombre'),
                  'saldo': cuenta.get('saldo'),
                  'tipo': 0
                });
              }
            }
            cuentas.sort((a, b) => a['nombre'].compareTo(b['nombre']));
            cuentas.add({'nombre': 'Agregar Cuenta', 'saldo': 0, 'tipo': 1});
            return CarouselSlider(
              options: CarouselOptions(height: 100.0),
              items: cuentas.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: i['tipo'] == 0
                          ? () {
                              accountProvider.reset();
                              accountProvider.id = i['id'];
                              // locator<NavigationService>()
                              //     .navigateTo('/account?i=${i['id']}');
                              locator<NavigationService>()
                                  .navigateTo('/account');
                            }
                          : () {
                              accountProvider.reset();
                              locator<NavigationService>()
                                  .navigateTo('/account');
                            },
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 15.0),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black38,
                                    blurStyle: BlurStyle.solid,
                                    blurRadius: 10)
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("${i['nombre']}",
                                    style: GoogleFonts.montserratAlternates(
                                        color: Colors.black54, fontSize: 20)),
                                if (i['tipo'] == 0)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text("Saldo neto",
                                          style:
                                              GoogleFonts.montserratAlternates(
                                                  color: Colors.black54,
                                                  fontSize: 16)),
                                      Text("\$ ${i['saldo']}",
                                          style:
                                              GoogleFonts.montserratAlternates(
                                                  color: double.parse(
                                                              "${i['saldo']}") <
                                                          0
                                                      ? Colors.redAccent
                                                      : Colors.greenAccent,
                                                  fontSize: 16)),
                                    ],
                                  )
                              ],
                            ),
                          )),
                    );
                  },
                );
              }).toList(),
            );
          } else {
            List<Map<String, dynamic>> cuentas = [];
            cuentas.add({'nombre': 'Agregar Cuenta', 'saldo': 0, 'tipo': 1});
            return CarouselSlider(
              options: CarouselOptions(height: 130.0),
              items: cuentas.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black38,
                                  blurStyle: BlurStyle.solid,
                                  blurRadius: 10)
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: i['tipo'] == 0
                                    ? null
                                    : () => locator<NavigationService>()
                                        .navigateTo('/account'),
                                child: Text("${i['nombre']}",
                                    style: GoogleFonts.montserratAlternates(
                                        color: Colors.black54, fontSize: 20)),
                              ),
                              if (i['tipo'] == 0)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text("Saldo neto",
                                        style: GoogleFonts.montserratAlternates(
                                            color: Colors.black54,
                                            fontSize: 16)),
                                    Text("\$ ${i['saldo']}",
                                        style: GoogleFonts.montserratAlternates(
                                            color:
                                                double.parse("${i['saldo']}") <
                                                        0
                                                    ? Colors.redAccent
                                                    : Colors.greenAccent,
                                            fontSize: 16)),
                                  ],
                                )
                            ],
                          ),
                        ));
                  },
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
