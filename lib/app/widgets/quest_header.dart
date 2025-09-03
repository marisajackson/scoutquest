import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/data/repositories/clue_repository.dart';

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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Time Breakdown',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Actual Time:',
                            style: TextStyle(fontSize: 16)),
                        Text(
                          _formatDuration(actualElapsed),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Penalty Time:',
                            style: TextStyle(fontSize: 16)),
                        Text(
                          '+$_penaltyMinutes min',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _penaltyMinutes > 0
                                ? Colors.orange[700]
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Time:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _elapsedTime,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        dialogTimer?.cancel();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
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
                style: const TextStyle(
                  fontSize: 20.0,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
