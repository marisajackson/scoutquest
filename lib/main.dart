import 'package:flutter/material.dart';
import 'package:scoutquest/app.routes.dart';
import 'package:scoutquest/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Core());
}

class Core extends StatelessWidget {
  const Core({super.key});

  @override
  Widget build(BuildContext context) {
    return const Lava();
  }
}

class Lava extends StatelessWidget {
  const Lava({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scout Quest',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: initialRoute,
      routes: routes,
    );
  }
}
