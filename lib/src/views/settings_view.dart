import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../locator.dart';
import '../providers/providers.dart';
import '../services/navigation_service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: 600,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
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
              child: ListTile(
                title: Text(
                  'Cerrar Sesión',
                  // textAlign: TextAlign.center,
                  style: GoogleFonts.montserratAlternates(),
                ),
                leading: const Icon(Icons.logout),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(
                'Versión: 1.2.0',
                style: GoogleFonts.montserratAlternates(
                    // fontSize: 10,
                    fontStyle: FontStyle.italic),
              ),
            )
          ],
        ),
      ),
    );
  }
}
