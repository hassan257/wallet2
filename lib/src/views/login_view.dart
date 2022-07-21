import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../locator.dart';
import '../services/navigation_service.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _BotonGoogle(),
          ],
        ),
      ),
    );
  }
}

class _BotonGoogle extends StatelessWidget {
  const _BotonGoogle({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Botón para iniciar sesión con Google',
      child: GestureDetector(
        onTap: () async {
          // ignore: unused_local_variable
          final User? user = await currentUser();
          locator<NavigationService>().navigateTo('/home');
        },
        child: Container(
          // height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          decoration: BoxDecoration(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              FaIcon(
                FontAwesomeIcons.google,
                // color: theme.darkTheme ? Colors.blue : Colors.white,
                color: Colors.white,
                size: 28,
              ),
              // Spacer(),
              Text(
                'Iniciar Sesión con Google',
                style: TextStyle(
                    // color: theme.darkTheme ? Colors.blue : Colors.white,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              )
            ],
          ),
        ),
      ),
    );
  }

  currentUser() async {
    await Firebase.initializeApp();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication authentication =
        await account!.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken);
    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User? user = authResult.user;

    return user;
  }
}
