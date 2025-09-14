import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:scoutquest/app.routes.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/app/widgets/app_bar_manager.dart';
import 'package:scoutquest/app/widgets/score_submission_bottom_sheet.dart';
import 'package:scoutquest/data/repositories/quest_repository.dart';

class QuestComplete extends StatelessWidget {
  final Quest quest;
  const QuestComplete({super.key, required this.quest});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);
    final seconds = (duration.inSeconds % 60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showScoreSubmissionBottomSheet(
      BuildContext context, Duration duration) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScoreSubmissionBottomSheet(
        quest: quest,
        duration: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fetch duration from repository
    final repo = QuestRepository();

    return Scaffold(
      appBar: AppBarManager(
        appBar: AppBar(),
        hasBackButton: true,
        backButtonOnPressed: () => Navigator.of(context).pushNamed(questsRoute),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: repo.getUserQuest(quest.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data;
            if (data == null) {
              return const Center(child: Text("No data available"));
            }
            final duration = Duration(seconds: data['totalDuration'] ?? 0);
            final penaltyMinutes = data['penalty'] ?? 0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // icon
                const Icon(
                  Icons.timer_outlined,
                  size: 100,
                ),
                Html(
                  data:
                      "<div style='text-align: center; font-size: 20px; font-weight: bold;'>${quest.completionHtml}</div>",
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                if (penaltyMinutes > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    "(includes +$penaltyMinutes min penalty)",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  "Think you've claimed the fastest time?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Submit your time and see how you stack up.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FloatingActionButton.extended(
                  onPressed: () =>
                      _showScoreSubmissionBottomSheet(context, duration),
                  label: const Text(
                    'Submit Score',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
