import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Duration?>(
          future: repo.getQuestDuration(quest.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final duration = snapshot.data ?? Duration.zero;
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
                const SizedBox(height: 12),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "Think you’ve claimed the fastest time?",
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
