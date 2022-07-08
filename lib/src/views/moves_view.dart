import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import '../providers/providers.dart';
import '../services/navigation_service.dart';
import '../widgets/cuentas.dart';
import '../widgets/widgets.dart';

class MovesView extends StatelessWidget {
  const MovesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    AddMoveProvider addMoveProvider = Provider.of<AddMoveProvider>(context);
    return SafeArea(
      child: Stack(
        children: [
          Wrap(
            children: [
              Column(
                children: const [Cuentas(), _MovesBar(), _LayoutView()],
              ),
            ],
          ),
          Positioned(
            bottom: 0,
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

class _LayoutView extends StatelessWidget {
  const _LayoutView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MovesViewProvider movesViewProvider =
        Provider.of<MovesViewProvider>(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final Timestamp fechaInicial = Timestamp.fromDate(DateTime(
        movesViewProvider.currentDate.year,
        movesViewProvider.currentDate.month));
    final Timestamp fechaFinal = Timestamp.fromDate(DateTime(
        movesViewProvider.currentDate.year,
        movesViewProvider.currentDate.month + 1));
    Query<Map<String, dynamic>> stream = FirebaseFirestore.instance
        .doc('users/${currentUser!.uid}')
        .collection('moves');
    stream = stream.where('fecha', isGreaterThanOrEqualTo: fechaInicial);
    stream = stream.where('fecha', isLessThan: fechaFinal);
    // .snapshots();
    switch (movesViewProvider.index) {
      case 1:
        stream = stream.where('tipo', isEqualTo: 'GASTO');
        break;
      case 2:
        stream = stream.where('tipo', isEqualTo: 'INGRESO');
        break;
      default:
    }
    return Column(
      children: [
        const _Tools(),
        StreamBuilder(
          stream: stream.snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasData) {
              final items = snapshot.data!.docs;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                height: 360,
                child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      // final fecha = DateTime.parse(items[index].get('fecha'));
                      final Timestamp fechaTimestamp =
                          items[index].get('fecha');
                      final DateTime fechaDateTime = fechaTimestamp.toDate();
                      final String fecha =
                          "${fechaDateTime.day}/${fechaDateTime.month}/${fechaDateTime.year}";
                      return Dismissible(
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            await Alerts().confirmDialog(
                                context: context,
                                message: '¿Confirma eliminar el movimiento?',
                                button1Function: () async {
                                  // Obtener datos de la cuenta
                                  final DocumentSnapshot<Map<String, dynamic>>
                                      cuenta = await FirebaseFirestore.instance
                                          .doc('users/${currentUser.uid}')
                                          .collection('accounts')
                                          .doc(
                                              '${items[index].get('cuenta_id')}')
                                          .get();
                                  final saldoMovimiento = (items[index]
                                              .get('tipo') ==
                                          'INGRESO')
                                      ? double.parse(
                                              "${items[index].get('cantidad')}") *
                                          -1
                                      : double.parse(
                                          "${items[index].get('cantidad')}");
                                  final saldo =
                                      double.parse("${cuenta.get('saldo')}") +
                                          saldoMovimiento;
                                  // Actualizar el saldo
                                  await FirebaseFirestore.instance
                                      .doc('users/${currentUser.uid}')
                                      .collection('accounts')
                                      .doc('${items[index].get('cuenta_id')}')
                                      .update({'saldo': saldo});
                                  // Eliminar movimiento
                                  await FirebaseFirestore.instance
                                      .doc('users/${currentUser.uid}')
                                      .collection('moves')
                                      .doc(items[index].id)
                                      .delete();
                                  Navigator.pop(context);
                                  return null;
                                },
                                button1Text: 'Si',
                                button2Function: () async {
                                  Navigator.pop(context);
                                  return null;
                                },
                                button2Text: 'No');
                          } else {
                            AddMoveProvider addMoveProvider =
                                Provider.of<AddMoveProvider>(context,
                                    listen: false);
                            addMoveProvider.reset();
                            addMoveProvider.id = items[index].id;
                            addMoveProvider.isGasto =
                                (items[index].get('tipo') == 'GASTO')
                                    ? true
                                    : false;
                            addMoveProvider.cuenta =
                                "${items[index].get('cuenta_id')}\$${items[index].get('cuenta')}";
                            if (items[index].get('tipo') == 'INGRESO') {
                              addMoveProvider.conceptoIngreso =
                                  items[index].get('categoria_id') +
                                      '\$' +
                                      items[index].get('categoria');
                              addMoveProvider.conceptoGasto = '';
                            } else {
                              addMoveProvider.conceptoIngreso = '';
                              addMoveProvider.conceptoGasto =
                                  items[index].get('categoria_id') +
                                      '\$' +
                                      items[index].get('categoria');
                            }
                            addMoveProvider.importe =
                                items[index].get('cantidad');
                            addMoveProvider.movimiento =
                                items[index].get('nombre');
                            addMoveProvider.fecha = items[index].get('fecha');
                            addMoveProvider.descripcion =
                                items[index].get('descripcion');
                            addMoveProvider.saldoAnterior =
                                double.parse(items[index].get('cantidad'));
                            addMoveProvider.tipoMovimientoAnterior =
                                items[index].get('tipo');
                            locator<NavigationService>().navigateTo('/addmove');
                          }
                          return null;
                        },
                        // direction: DismissDirection.startToEnd,
                        key: ValueKey(items[index].id),
                        background: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          color: Colors.red,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                'Eliminar',
                                style: GoogleFonts.montserratAlternates(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          color: Colors.blue,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Modificar',
                                style: GoogleFonts.montserratAlternates(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        onDismissed: (direction) {
                          // if (direction == DismissDirection.endToStart) {
                          //   AddMoveProvider addMoveProvider =
                          //       Provider.of<AddMoveProvider>(context,
                          //           listen: false);
                          //   addMoveProvider.reset();
                          //   addMoveProvider.id = items[index].id;
                          //   addMoveProvider.isGasto =
                          //       (items[index].get('tipo') == 'GASTO')
                          //           ? true
                          //           : false;
                          //   addMoveProvider.cuenta =
                          //       "${items[index].get('cuenta_id')}\$${items[index].get('cuenta')}";
                          //   if (items[index].get('tipo') == 'INGRESO') {
                          //     addMoveProvider.conceptoIngreso =
                          //         items[index].get('categoria_id') +
                          //             '\$' +
                          //             items[index].get('categoria');
                          //     addMoveProvider.conceptoGasto = '';
                          //   } else {
                          //     addMoveProvider.conceptoIngreso = '';
                          //     addMoveProvider.conceptoGasto =
                          //         items[index].get('categoria_id') +
                          //             '\$' +
                          //             items[index].get('categoria');
                          //   }
                          //   addMoveProvider.importe = items[index].get('cantidad');
                          //   addMoveProvider.movimiento = items[index].get('nombre');
                          //   addMoveProvider.fecha = items[index].get('fecha');
                          //   addMoveProvider.descripcion =
                          //       items[index].get('descripcion');
                          //   locator<NavigationService>().navigateTo('/addmove');
                          // } else {}
                        },
                        child: ListTile(
                          dense: true,
                          isThreeLine: true,
                          title: Wrap(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    items[index].get('nombre'),
                                    style: GoogleFonts.montserratAlternates(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  Text(
                                    "\$ ${items[index].get('cantidad')}",
                                    style: GoogleFonts.montserratAlternates(
                                        color:
                                            items[index].get('tipo') == 'GASTO'
                                                ? Colors.redAccent
                                                : Colors.greenAccent,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ],
                          ),
                          subtitle: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    fecha,
                                    style: GoogleFonts.montserratAlternates(
                                        color: Colors.black38,
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  Text(
                                    "${items[index].get('categoria')}",
                                    softWrap: true,
                                    style: GoogleFonts.montserratAlternates(
                                        color: Colors.black38,
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                              Text(
                                items[index].get('cuenta'),
                                style: GoogleFonts.montserratAlternates(
                                    color: Colors.black38,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => Container(
                          color: Colors.black12,
                          height: 2,
                        ),
                    itemCount: items.length),
              );
            } else {
              return Container();
            }
          },
        ),
      ],
    );
  }
}

class _Tools extends StatelessWidget {
  const _Tools({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MovesViewProvider movesViewProvider =
        Provider.of<MovesViewProvider>(context);
    final months = [
      {'id': DateTime.january, 'month': 'Enero'},
      {'id': DateTime.february, 'month': 'Febrero'},
      {'id': DateTime.march, 'month': 'Marzo'},
      {'id': DateTime.april, 'month': 'Abril'},
      {'id': DateTime.may, 'month': 'Mayo'},
      {'id': DateTime.june, 'month': 'Junio'},
      {'id': DateTime.july, 'month': 'Julio'},
      {'id': DateTime.august, 'month': 'Agosto'},
      {'id': DateTime.september, 'month': 'Septiembre'},
      {'id': DateTime.october, 'month': 'Octubre'},
      {'id': DateTime.november, 'month': 'Noviembre'},
      {'id': DateTime.december, 'month': 'Diciembre'},
    ];

    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Text(
            'Mes',
            style: GoogleFonts.montserratAlternates(
                color: Colors.pinkAccent, fontWeight: FontWeight.bold),
          ),
          DropdownButton<int>(
            value: movesViewProvider.currentDate.month,
            items: months.map((Map<String, dynamic> items) {
              return DropdownMenuItem<int>(
                value: items['id'],
                child: Text(
                  items['month'],
                  style: GoogleFonts.montserratAlternates(
                    color: Colors.grey[600],
                    //fontWeight: FontWeight.bold
                  ),
                ),
              );
            }).toList(),
            onChanged: (int? value) {
              movesViewProvider.currentDate =
                  DateTime(movesViewProvider.currentDate.year, value!);
            },
          ),
        ],
      ),
    );
  }
}

class _MovesBar extends StatelessWidget {
  const _MovesBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MovesViewProvider movesViewProvider =
        Provider.of<MovesViewProvider>(context);
    return BottomNavigationBar(
        selectedLabelStyle: GoogleFonts.montserratAlternates(),
        unselectedLabelStyle: GoogleFonts.montserratAlternates(),
        selectedItemColor: Colors.pinkAccent,
        currentIndex: movesViewProvider.index,
        onTap: (int index) {
          movesViewProvider.index = index;
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.all_inbox), label: 'Todos'),
          BottomNavigationBarItem(icon: Icon(Icons.money_off), label: 'Gastos'),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Ingresos'),
        ]);
  }
}
