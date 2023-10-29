import 'package:flutter/material.dart';
import 'package:scoutquest/app/screens/auth/auth_login.dart';
import 'package:scoutquest/app/screens/auth/auth_register.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;
  void toggleView() {
    setState(() => isSignIn = !isSignIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scout Quest'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isSignIn ? const AuthLogin() : const AuthRegister(),
        ),
      ),
    );
  }
}
