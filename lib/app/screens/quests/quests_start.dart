import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/app.routes.dart';
import 'package:scoutquest/app/widgets/app_bar_manager.dart';

class QuestsStart extends StatelessWidget {
  final Quest quest;
  const QuestsStart({super.key, required this.quest});

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
            Html(
              data:
                  "<div style='text-align: center; font-size: 20px; font-weight: bold;'>${quest.welcomeHtml}</div>",
            ),
            const Spacer(),
            FloatingActionButton.extended(
              onPressed: () => _startQuest(context),
              label: const Text(
                'Start Quest',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
