import 'package:flutter/material.dart';
import 'package:scoutquest/services/auth_service.dart';
import 'package:scoutquest/utils/logger.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  String email = '';
  String password = '';
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
  }

  // Register user with email and password
  Future<void> _loginWithEmail() async {
    Logger.log('logging in user');
    final dynamic user = await _auth.loginWithEmail(email, password);
    if (user == null) {
      Logger.log('Error logging in user');
    } else {
      Logger.log('User logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Login',
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
          onPressed: _loginWithEmail,
          child: const Text('Login'),
        ),
      ],
    );
  }
}
