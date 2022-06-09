import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet2/src/ui/layout/layouts.dart';

import 'locator.dart';
import 'src/providers/providers.dart';
import 'src/router/router.dart';
import 'src/services/navigation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await DBProvider.db.initDB();
  setupLocator();
  Flurorouter.configureRoutes();
  await Firebase.initializeApp();
  bool isLog = false;
  FirebaseAuth.instance.idTokenChanges().listen((User? user) {
    if (user == null) {
      isLog = false;
      // print('no token');
    } else {
      isLog = true;
      // print('si token');
    }
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavigationProvider()),
      ],
      child: MyApp(isLog: isLog),
    ));
  });
}

class MyApp extends StatelessWidget {
  final bool isLog;
  const MyApp({Key? key, required this.isLog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    BottomNavigationProvider bottomNavigationProvider =
        Provider.of<BottomNavigationProvider>(context);
    bottomNavigationProvider.isLog = isLog;
    return MaterialApp(
      initialRoute: (isLog) ? '/' : '/login',
      onGenerateRoute: Flurorouter.router.generator,
      navigatorKey: locator<NavigationService>().navigatorKey,
      builder: (_, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => PhoneLayout(child: child ?? Container()),
            ),
          ],
        );
      },
      theme: themeProvider.currentTheme,
      title: 'Material App',
    );
  }
}
