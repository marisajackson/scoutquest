import 'package:flutter/material.dart';
import 'package:scoutquest/services/auth_service.dart';
import 'package:scoutquest/utils/logger.dart';

class AuthRegister extends StatefulWidget {
  const AuthRegister({super.key});

  @override
  AuthRegisterState createState() => AuthRegisterState();
}

class AuthRegisterState extends State<AuthRegister> {
  String email = '';
  String password = '';
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
  }

  // Register user with email and password
  Future<void> _registerWithEmail() async {
    final dynamic user = await _auth.registerWithEmail(email, password);
    if (user == null) {
      Logger.log('Error registering user');
    } else {
      Logger.log('User registered');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'Sign Up',
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
            onChanged: (val) {
              setState(() => email = val);
            },
            validator: ((value) => value!.isEmpty
                ? 'Please enter an email'
                : value.contains('@')
                    ? null
                    : 'Please enter a valid email'),
          ),
        ),
        const SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
            onChanged: (val) {
              setState(() => password = val);
            },
            validator: ((value) => value!.isEmpty
                ? 'Please enter a password'
                : value.length < 6
                    ? 'Password must be at least 6 characters'
                    : null),
            obscureText: true,
          ),
        ),
        ElevatedButton(
          onPressed: _registerWithEmail,
          child: const Text('Sign Up'),
        ),
      ],
    );
  }
}
