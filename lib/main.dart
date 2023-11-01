import 'package:flutter/material.dart';
import 'package:scoutquest/app/screens/quests/quests_screen.dart';

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
    return const MaterialApp(
      title: 'Scout Quest',
      home: QuestsScreen(),
    );
  }
}
