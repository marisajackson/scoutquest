import 'package:flutter/material.dart';
import 'package:scoutquest/widgets/auth/login.dart';
import 'package:scoutquest/widgets/auth/register.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  AuthViewState createState() => AuthViewState();
}

class AuthViewState extends State<AuthView> {
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
          child: isSignIn ? const Login() : const Register(),
        ),
      ),
    );
  }
}
