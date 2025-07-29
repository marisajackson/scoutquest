import 'package:flutter/material.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/app/widgets/app_bar_manager.dart';
import 'package:scoutquest/app/widgets/score_submission_bottom_sheet.dart';
import 'package:scoutquest/data/repositories/quest_repository.dart';

class QuestComplete extends StatelessWidget {
  final Quest quest;
  const QuestComplete({super.key, required this.quest});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes minute${minutes == 1 ? '' : 's'} and $seconds second${seconds == 1 ? '' : 's'}';
    }
    return '$seconds second${seconds == 1 ? '' : 's'}';
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
                const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Congratulations!',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'You completed "${quest.name}" in ${_formatDuration(duration)}.',
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () =>
                      _showScoreSubmissionBottomSheet(context, duration),
                  child: const Text('Submit Score'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
