import 'package:flutter/material.dart';
import 'package:my_flutter_apk/pages/login_page.dart';
import 'package:my_flutter_apk/pages/sign_up_page.dart';

class LoginAndSignUp extends StatefulWidget {
  const LoginAndSignUp({super.key});
  @override
  State<LoginAndSignUp> createState() => _LoginAndSignUpState();
}

class _LoginAndSignUpState extends State<LoginAndSignUp> {
  bool islogin = true;

  void togglePages() {
    setState(() {
      islogin = !islogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (islogin) {
      return LoginPage(
        onPressed: togglePages,
      );
    } else {
      return SignUp(
        onPressed: togglePages,
      );
    }
  }
}
