import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/data/repositories/clue_repository.dart';
import 'package:scoutquest/utils/constants.dart';

class QuestHeader extends StatefulWidget implements PreferredSizeWidget {
  final Quest quest;
  final VoidCallback? onTimerTapped;

  const QuestHeader({
    super.key,
    required this.quest,
    this.onTimerTapped,
  });

  @override
  QuestHeaderState createState() => QuestHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

class QuestHeaderState extends State<QuestHeader> {
  String _elapsedTime = "00:00";
  int _penaltyMinutes = 0;
  Timer? _timer;

  late ClueRepository _clueRepository;
  Quest? _currentQuest;

  @override
  void initState() {
    super.initState();
    _clueRepository = ClueRepository(widget.quest);
    _currentQuest = widget.quest;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateElapsedTime();
    });
    _updateElapsedTime(); // Initial update
  }

  void _updateElapsedTime() {
    if (_currentQuest?.startTime != null) {
      final elapsed = DateTime.now().difference(_currentQuest!.startTime!);
      _loadPenaltyAndUpdateTime(elapsed);
    }
  }

  void _loadPenaltyAndUpdateTime(Duration elapsed) async {
    final penaltyMinutes = await _clueRepository.getTotalPenaltyMinutes();
    final totalElapsed = elapsed + Duration(minutes: penaltyMinutes);
    if (mounted) {
      setState(() {
        _elapsedTime = _formatDuration(totalElapsed);
        _penaltyMinutes = penaltyMinutes;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  void _showTimeBreakdown() {
    if (_currentQuest?.startTime == null) return;

    Timer? dialogTimer;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            final actualElapsed =
                DateTime.now().difference(_currentQuest!.startTime!);

            dialogTimer?.cancel();
            dialogTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (context.mounted) {
                setDialogState(() {});
              } else {
                timer.cancel();
              }
            });

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: ScoutQuestColors.primaryAction,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Time Breakdown',
                      style: TextStyle(
                        fontSize: ScoutQuestFontSizes.headerMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTimeRow(
                      'Actual Time:',
                      _formatDuration(actualElapsed),
                      ScoutQuestColors.primaryBackground,
                    ),
                    const SizedBox(height: 12),
                    _buildTimeRow(
                      'Penalty Time:',
                      '+$_penaltyMinutes min',
                      _penaltyMinutes > 0
                          ? ScoutQuestColors.primaryAction
                          : Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(
                        color: ScoutQuestColors.primaryAction,
                        thickness: 1,
                      ),
                    ),
                    _buildTimeRow(
                      'Total Time:',
                      _elapsedTime,
                      ScoutQuestColors.primaryAction,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        dialogTimer?.cancel();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ScoutQuestColors.primaryAction,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: ScoutQuestFontSizes.bodyRegular,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => dialogTimer?.cancel());
  }

  Widget _buildTimeRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ScoutQuestFontSizes.bodyRegular,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: ScoutQuestFontSizes.bodyRegular,
            fontWeight: FontWeight.bold,
            color: color,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.quest.name,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: ScoutQuestFontSizes.bodyLarge,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: widget.onTimerTapped ?? _showTimeBreakdown,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _elapsedTime,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScoutQuestFontSizes.bodySmall,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
