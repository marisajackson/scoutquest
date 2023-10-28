import 'package:flutter/material.dart';
import 'package:scoutquest/services/auth_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  String email = '';
  String password = '';
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
  }

  // Register user with email and password
  Future<void> _registerWithEmail() async {
    print('registering user');
    final dynamic user = await _auth.registerWithEmail(email, password);
    if (user == null) {
      print('Error registering user');
    } else {
      print('User registered');
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
