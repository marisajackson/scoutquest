import 'package:flutter/material.dart';
import 'package:scoutquest/app.routes.dart';
import 'package:scoutquest/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:scoutquest/deep_links.dart';

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

class Lava extends StatefulWidget {
  const Lava({super.key});

  @override
  State<Lava> createState() => _LavaState();
}

class _LavaState extends State<Lava> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await DeepLinkService.instance.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scout Quest',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      routes: routes,
    );
  }
}
