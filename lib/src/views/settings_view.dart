import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import '../providers/providers.dart';
import '../services/navigation_service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                BottomNavigationProvider bottomNavigationProvider =
                    Provider.of<BottomNavigationProvider>(context,
                        listen: false);
                bottomNavigationProvider.isLog = false;
                locator<NavigationService>().navigateTo('/login');
              },
              child: const ListTile(
                title: Text(
                  'Cerrar Sesión',
                  textAlign: TextAlign.center,
                ),
                leading: Icon(Icons.logout),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            )
          ],
        ),
      ),
    );
  }
}
