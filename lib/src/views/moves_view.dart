import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
            children: const [Cuentas(), _MovesBar(), _LayoutView()],
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
    final currentUser = FirebaseAuth.instance.currentUser;
    final Stream<QuerySnapshot<Map<String, dynamic>>> stream = FirebaseFirestore
        .instance
        .doc('users/${currentUser!.uid}')
        .collection('moves')
        .snapshots();
    return StreamBuilder(
      stream: stream,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          final items = snapshot.data!.docs;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            height: 360,
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
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
                      if (direction == DismissDirection.endToStart) {
                        AddMoveProvider addMoveProvider =
                            Provider.of<AddMoveProvider>(context,
                                listen: false);
                        addMoveProvider.reset();
                        locator<NavigationService>().navigateTo('/addmove');
                      } else {}
                    },
                    child: ListTile(
                      dense: true,
                      isThreeLine: true,
                      title: Wrap(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                    color: items[index].get('tipo') == 'GASTO'
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
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "${items[index].get('fecha')}",
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
