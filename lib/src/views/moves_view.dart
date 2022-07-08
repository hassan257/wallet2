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
          // Wrap(
          //   children: [
          //     Column(
          //       children: const [Cuentas(), _MovesBar(), _LayoutView()],
          //     ),
          //   ],
          // ),
          const _LayoutView(),
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

class _MainScroll extends StatelessWidget {
  final List<Widget> elements;
  const _MainScroll({Key? key, required this.elements}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          floating: true,
          delegate: _SliverCustomHeaderDelegate(
              minHeight: 250,
              maxHeight: 300,
              child: Wrap(
                children: [
                  Column(
                    children: const [
                      Cuentas(),
                      _MovesBar(),
                      _Tools(),
                    ],
                  ),
                ],
              )),
        ),
        SliverList(delegate: SliverChildListDelegate(elements))
      ],
    );
  }
}

class _SliverCustomHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;
  _SliverCustomHeaderDelegate(
      {required this.minHeight, required this.maxHeight, required this.child});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: child,
    );
  }

  @override
  double get maxExtent => maxHeight > minHeight ? maxHeight : minHeight;

  @override
  double get minExtent => minHeight < maxHeight ? minHeight : maxHeight;

  @override
  bool shouldRebuild(_SliverCustomHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
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
    stream = stream.orderBy('fecha', descending: true);
    switch (movesViewProvider.index) {
      case 1:
        stream = stream.where('tipo', isEqualTo: 'GASTO');
        break;
      case 2:
        stream = stream.where('tipo', isEqualTo: 'INGRESO');
        break;
      default:
    }
    return _ConstructorListaMovimientos(
        stream: stream, currentUser: currentUser);
  }
}

class _ConstructorListaMovimientos extends StatelessWidget {
  const _ConstructorListaMovimientos({
    Key? key,
    required this.stream,
    required this.currentUser,
  }) : super(key: key);

  final Query<Map<String, dynamic>> stream;
  final User? currentUser;

  @override
  Widget build(BuildContext context) {
    int index = 0;
    return StreamBuilder(
      stream: stream.snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          final items = snapshot.data!.docs;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            // height: 360,
            child: _MainScroll(
                elements: items.map((item) {
              final Timestamp fechaTimestamp = item.get('fecha');
              final DateTime fechaDateTime = fechaTimestamp.toDate();
              final String fecha =
                  "${fechaDateTime.day}/${fechaDateTime.month}/${fechaDateTime.year}";
              index++;
              if (index == 10) {
                index = 0;
                return Column(
                  children: [
                    _TarjetaMovimiento(
                        currentUser: currentUser, fecha: fecha, item: item),
                    const NativeInlineWidget()
                  ],
                );
              }
              return _TarjetaMovimiento(
                  currentUser: currentUser, fecha: fecha, item: item);
            }).toList()),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class _TarjetaMovimiento extends StatelessWidget {
  const _TarjetaMovimiento({
    Key? key,
    required this.currentUser,
    required this.fecha,
    required this.item,
  }) : super(key: key);

  final User? currentUser;
  final String fecha;
  final QueryDocumentSnapshot<Map<String, dynamic>> item;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await Alerts().confirmDialog(
              context: context,
              message: '¿Confirma eliminar el movimiento?',
              button1Function: () async {
                // Obtener datos de la cuenta
                final DocumentSnapshot<Map<String, dynamic>> cuenta =
                    await FirebaseFirestore.instance
                        .doc('users/${currentUser!.uid}')
                        .collection('accounts')
                        .doc('${item.get('cuenta_id')}')
                        .get();
                final saldoMovimiento = (item.get('tipo') == 'INGRESO')
                    ? double.parse("${item.get('cantidad')}") * -1
                    : double.parse("${item.get('cantidad')}");
                final saldo =
                    double.parse("${cuenta.get('saldo')}") + saldoMovimiento;
                // Actualizar el saldo
                await FirebaseFirestore.instance
                    .doc('users/${currentUser!.uid}')
                    .collection('accounts')
                    .doc('${item.get('cuenta_id')}')
                    .update({'saldo': saldo});
                // Eliminar movimiento
                await FirebaseFirestore.instance
                    .doc('users/${currentUser!.uid}')
                    .collection('moves')
                    .doc(item.id)
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
              Provider.of<AddMoveProvider>(context, listen: false);
          addMoveProvider.reset();
          addMoveProvider.id = item.id;
          addMoveProvider.isGasto =
              (item.get('tipo') == 'GASTO') ? true : false;
          addMoveProvider.cuenta =
              "${item.get('cuenta_id')}\$${item.get('cuenta')}";
          if (item.get('tipo') == 'INGRESO') {
            addMoveProvider.conceptoIngreso =
                item.get('categoria_id') + '\$' + item.get('categoria');
            addMoveProvider.conceptoGasto = '';
          } else {
            addMoveProvider.conceptoIngreso = '';
            addMoveProvider.conceptoGasto =
                item.get('categoria_id') + '\$' + item.get('categoria');
          }
          addMoveProvider.importe = item.get('cantidad');
          addMoveProvider.movimiento = item.get('nombre');
          addMoveProvider.fecha = item.get('fecha');
          addMoveProvider.descripcion = item.get('descripcion');
          addMoveProvider.saldoAnterior = double.parse(item.get('cantidad'));
          addMoveProvider.tipoMovimientoAnterior = item.get('tipo');
          locator<NavigationService>().navigateTo('/addmove');
        }
        return null;
      },
      key: ValueKey(item.id),
      background: const _BackgroundDismissable(),
      secondaryBackground: const _SecondaryBackgroundDismissable(),
      child: _ContenidoTarjetaMovimiento(item: item, fecha: fecha),
    );
  }
}

class _ContenidoTarjetaMovimiento extends StatelessWidget {
  const _ContenidoTarjetaMovimiento({
    Key? key,
    required this.item,
    required this.fecha,
  }) : super(key: key);

  final QueryDocumentSnapshot<Map<String, dynamic>> item;
  final String fecha;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      isThreeLine: true,
      title: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.get('nombre'),
                  style: GoogleFonts.montserratAlternates(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Text(
                  "\$ ${item.get('cantidad')}",
                  style: GoogleFonts.montserratAlternates(
                      color: item.get('tipo') == 'GASTO'
                          ? Colors.redAccent
                          : Colors.greenAccent,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ],
      ),
      subtitle: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                fecha,
                style: GoogleFonts.montserratAlternates(
                    color: Colors.black38,
                    fontSize: 14,
                    fontStyle: FontStyle.italic),
              ),
              Text(
                "${item.get('categoria')}",
                softWrap: true,
                style: GoogleFonts.montserratAlternates(
                    color: Colors.black38,
                    fontSize: 14,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
          Text(
            item.get('cuenta'),
            style: GoogleFonts.montserratAlternates(
                color: Colors.black38,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _SecondaryBackgroundDismissable extends StatelessWidget {
  const _SecondaryBackgroundDismissable({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Modificar',
            style: GoogleFonts.montserratAlternates(
                color: Colors.white, fontWeight: FontWeight.bold),
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
    );
  }
}

class _BackgroundDismissable extends StatelessWidget {
  const _BackgroundDismissable({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                color: Colors.white, fontWeight: FontWeight.bold),
          )
        ],
      ),
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
