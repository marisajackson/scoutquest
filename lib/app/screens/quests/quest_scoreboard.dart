import 'package:flutter/material.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/app/models/score.dart';
import 'package:scoutquest/app/widgets/app_bar_manager.dart';
import 'package:scoutquest/data/repositories/score_repository.dart';
import 'package:scoutquest/utils/constants.dart';
import 'package:scoutquest/utils/logger.dart';
import 'package:scoutquest/app.routes.dart';

class QuestScoreboard extends StatefulWidget {
  final Quest quest;

  const QuestScoreboard({
    super.key,
    required this.quest,
  });

  @override
  State<QuestScoreboard> createState() => _QuestScoreboardState();
}

class _QuestScoreboardState extends State<QuestScoreboard> {
  final ScoreRepository _scoreRepository = ScoreRepository();
  List<Score> entries = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final scores = await _scoreRepository.fetchScores(widget.quest.id);

      setState(() {
        entries = scores;
        isLoading = false;
      });
    } catch (e) {
      Logger.log('Error loading scores: $e');
      setState(() {
        errorMessage = 'Failed to load scoreboard';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarManager(
        appBar: AppBar(),
        hasBackButton: true,
        backButtonOnPressed: () => {
          Navigator.of(context).pushReplacementNamed(questsRoute),
        },
      ),
      body: Column(
        children: [
          // Header with quest name and scoreboard subtitle
          Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            alignment: Alignment.center,
            color: ScoutQuestColors.primaryAction,
            child: Column(
              children: [
                Text(
                  widget.quest.name,
                  style: const TextStyle(
                    fontSize: 24.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Scoreboard',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadScores,
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadScores,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ScoutQuestColors.primaryAction,
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.leaderboard_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No scores yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to complete this quest!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Sort entries by duration (fastest first)
    final sortedEntries = List<Score>.from(entries)
      ..sort((a, b) => a.duration.compareTo(b.duration));

    return ListView.builder(
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        return _buildScoreboardItem(entry, index + 1);
      },
    );
  }

  Widget _buildScoreboardItem(Score entry, int position) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
        border: position <= 3
            ? Border.all(
                color: _getPositionColor(position),
                width: 2,
              )
            : null,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: _getPositionColor(position),
          radius: 20,
          child: Text(
            position.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          entry.teamName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getPositionColor(position).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getPositionColor(position).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            _formatDuration(entry.duration),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getPositionColor(position),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return ScoutQuestColors.primaryAction;
    }
  }

  IconData _getPositionIcon(int position) {
    switch (position) {
      case 1:
        return Icons.emoji_events; // Trophy
      case 2:
        return Icons.military_tech; // Medal
      case 3:
        return Icons.workspace_premium; // Badge
      default:
        return Icons.star;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
