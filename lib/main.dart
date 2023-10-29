import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoutquest/services/auth_service.dart';
import 'package:scoutquest/config/firebase_options.dart';
import 'package:scoutquest/app/screens/auth/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:scoutquest/app/screens/clues/clues_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const Core());
}

class Core extends StatelessWidget {
  const Core({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: const Lava(),
    );
  }
}

class Lava extends StatelessWidget {
  const Lava({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: 'Scout Quest',
        home: user == null ? const AuthScreen() : const CluesScreen(),
      ),
    );
  }
}
