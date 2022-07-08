import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wallet2/src/widgets/widgets.dart';

import '../../../locator.dart';
import '../../providers/providers.dart';
import '../../services/navigation_service.dart';

class PhoneLayout extends StatelessWidget {
  final Widget child;
  // final bool isLog;
  const PhoneLayout({
    Key? key,
    required this.child,
    // required this.isLog
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BottomNavigationProvider bottomNavigationProvider =
        Provider.of<BottomNavigationProvider>(context);
    final routes = ['/home', '/moves', '/settings'];
    return Scaffold(
      body: child,
      bottomNavigationBar: (bottomNavigationProvider.isLog)
          ? SizedBox(
              height: 125,
              child: Wrap(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const BannerInlineWidget(),
                      _CustomNavigationBar(
                          bottomNavigationProvider: bottomNavigationProvider,
                          routes: routes),
                    ],
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class _CustomNavigationBar extends StatelessWidget {
  const _CustomNavigationBar({
    Key? key,
    required this.bottomNavigationProvider,
    required this.routes,
  }) : super(key: key);

  final BottomNavigationProvider bottomNavigationProvider;
  final List<String> routes;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Barra de Navegación',
      child: BottomNavigationBar(
        selectedLabelStyle: GoogleFonts.montserratAlternates(),
        unselectedLabelStyle: GoogleFonts.montserratAlternates(),
        selectedItemColor: Colors.pinkAccent,
        currentIndex: bottomNavigationProvider.index,
        onTap: (int index) {
          bottomNavigationProvider.index = index;
          locator<NavigationService>().navigateTo(routes[index]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Movimientos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Preferencias')
        ],
      ),
    );
  }
}
