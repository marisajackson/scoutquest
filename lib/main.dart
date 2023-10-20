import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scoutquest/views/clue_list_view.dart';
import 'firebase_options.dart';

void main() => runApp(const Core());

class Core extends StatelessWidget {
  const Core({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    initializeFirebase();
    return const Lava();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

class Lava extends StatelessWidget {
  const Lava({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Scout Quest',
      home: ClueListView(),
    );
  }
}
