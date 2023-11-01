import 'package:flutter/material.dart';
import 'package:scoutquest/app.routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const Core());
}

class Core extends StatelessWidget {
  const Core({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Lava();
  }
}

class Lava extends StatelessWidget {
  const Lava({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scout Quest',
      // home: CluesScreen(),
      initialRoute: initialRoute,
      routes: routes,
    );
  }
}
