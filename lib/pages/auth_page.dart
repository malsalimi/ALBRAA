import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_apk/pages/Search.dart';
import 'package:my_flutter_apk/pages/login_or_signup.dart';
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // show a loading indicator while the checking the authentication state
              return const CircularProgressIndicator();
            } else {
              if (snapshot.hasData) {
                return const UrlScannerApp();
              } else {
                return const LoginAndSignUp();
              }
            }
          }),
    );
  }
}
