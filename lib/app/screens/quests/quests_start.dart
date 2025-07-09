import 'package:flutter/material.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/app.routes.dart';
import 'package:scoutquest/app/widgets/app_bar_manager.dart';

class QuestsStart extends StatelessWidget {
  final Quest quest;
  const QuestsStart({Key? key, required this.quest}) : super(key: key);

  void _startQuest(BuildContext context) {
    Navigator.of(context).pushNamed(cluesRoute, arguments: quest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarManager(
        appBar: AppBar(),
        hasBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Welcome to ${quest.name}!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Get ready to start your quest. Press the button below when you are ready.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _startQuest(context),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: const Text('Start Quest'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
