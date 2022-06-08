import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          ? Semantics(
              label: 'Barra de Navegación',
              child: BottomNavigationBar(
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
            )
          : null,
    );
  }
}
