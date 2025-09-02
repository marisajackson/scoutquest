import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scoutquest/app/models/clue.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/app/widgets/app_bar_manager.dart';
import 'package:scoutquest/data/repositories/clue_repository.dart';
import 'package:scoutquest/data/repositories/quest_repository.dart';
import 'package:scoutquest/utils/alert.dart';
import 'package:scoutquest/utils/constants.dart';

class ClueDetailScreen extends StatefulWidget {
  final Clue clue;
  final Quest quest;

  const ClueDetailScreen({
    super.key,
    required this.clue,
    required this.quest,
  });

  @override
  ClueDetailScreenState createState() => ClueDetailScreenState();
}

class ClueDetailScreenState extends State<ClueDetailScreen> {
  late ClueRepository clueRepository;
  TextEditingController? _codeController;
  List<String>? _draggableItems;
  bool secretCodeIncorrect = false;
  String _elapsedTime = "00:00";
  Timer? _timer;

  ClueStep get _currentStep => widget.clue.steps.firstWhere(
        (s) => s.step == widget.clue.progressStep,
        orElse: () => widget.clue.steps.first,
      );

  @override
  void initState() {
    super.initState();
    clueRepository = ClueRepository(widget.quest);
    _startTimer();

    // init controller if secretCode step
    if (_currentStep.secretCode != null) {
      _codeController = TextEditingController();
    }
    // init draggable if correctOrder step
    if (_currentStep.correctOrder != null) {
      _draggableItems = List.from(_currentStep.correctOrder!)..shuffle();
    }
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
    if (widget.quest.startTime != null) {
      final elapsed = DateTime.now().difference(widget.quest.startTime!);
      _loadPenaltyAndUpdateTime(elapsed);
    }
  }

  void _loadPenaltyAndUpdateTime(Duration elapsed) async {
    final penaltyMinutes = await clueRepository.getTotalPenaltyMinutes();
    final totalElapsed = elapsed + Duration(minutes: penaltyMinutes);
    setState(() {
      _elapsedTime = _formatDuration(totalElapsed);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarManager(
          appBar: AppBar(),
          hasBackButton: true,
          backButtonOnPressed: () => Navigator.of(context).pop(),
          questName: widget.quest.name,
          timer: _elapsedTime,
          actions: [
            // help button
            IconButton(
              icon: const Icon(Icons.help_outline, size: 32),
              onPressed: () {
                // Show help dialog or tooltip
              },
            ),
          ]),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            widget.clue.label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildStepContent(_currentStep),
                  if (widget.clue.status == ClueStatus.completed)
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Back to Quest',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (widget.clue.status != ClueStatus.completed)
                    TextButton(
                      onPressed: _showHintModal,
                      child: const Text(
                        'I need a hint!',
                        style: TextStyle(
                          color: ScoutQuestColors.accentAction,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(ClueStep step) {
    // unified UI: use available optional fields
    final hasOrder = step.correctOrder != null;
    final hasCode = step.secretCode != null;

    if (hasOrder) return _buildDragAndDrop(step);
    if (hasCode) return _buildSecretCodeEntry(step);

    // default: display HTML or plain text
    return Column(
      children: [
        Html(
          data:
              "<div style='text-align: center; font-size: 18px; font-weight: bold;'>${step.text}</div>",
        ),
        const SizedBox(height: 24),
        if (step.step < widget.clue.steps.length - 1)
          ElevatedButton(onPressed: _advance, child: const Text('Next')),
      ],
    );
  }

  Widget _buildDragAndDrop(ClueStep step) {
    return Column(children: [
      Html(
        data:
            "<div style='text-align: center; font-size: 18px; font-weight: bold;'>${step.text}</div>",
      ),
      const SizedBox(height: 12),
      ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onReorder: (oldIndex, newIndex) => setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _draggableItems!.removeAt(oldIndex);
          _draggableItems!.insert(newIndex, item);
        }),
        buildDefaultDragHandles: false,
        proxyDecorator: (child, _, anim) => FadeTransition(
          opacity: anim.drive(Tween(begin: 0.8, end: 1.0)),
          child: Material(type: MaterialType.transparency, child: child),
        ),
        children: [
          for (int i = 0; i < _draggableItems!.length; i++)
            Align(
              key: ValueKey(_draggableItems![i]),
              alignment: Alignment.center,
              widthFactor: 1.0,
              child: ReorderableDragStartListener(
                index: i,
                child: Container(
                  width: 250,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.drag_indicator, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _draggableItems![i],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        ),
        onPressed: _submitOrder,
        child: const Text('Submit',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
      ),
    ]);
  }

  Widget _buildSecretCodeEntry(ClueStep step) {
    return Column(children: [
      Html(
        data:
            "<div style='text-align: center; font-size: 20px; font-weight: bold;'>${step.text}</div>",
      ),
      const SizedBox(height: 24),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: _codeController,
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          decoration:
              defaultInputDecoration.copyWith(labelText: 'Enter Secret Code'),
        ),
      ),
      if (secretCodeIncorrect)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('Incorrect code',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      const SizedBox(height: 16),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        ),
        onPressed: () {
          // remove all spaces
          if (_codeController!.text.toLowerCase().replaceAll(' ', '') ==
              step.secretCode!.toLowerCase().replaceAll(' ', '')) {
            _advance();
          } else {
            Alert.toast('Incorrect code', ToastGravity.CENTER);
            setState(() => secretCodeIncorrect = true);
          }
        },
        child: const Text('Submit',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
      ),
    ]);
  }

  void _submitOrder() {
    if (listEquals(_draggableItems, _currentStep.correctOrder)) {
      _advance();
    } else {
      Alert.toast('Incorrect order', ToastGravity.CENTER);
    }
  }

  Future<void> _advance() async {
    setState(() {
      widget.clue.progressStep++;
      clueRepository.updateClueProgress(
        widget.clue.id,
        widget.clue.progressStep,
      );
      // re-init for next step
      final next = _currentStep;

      if (next.secretCode != null) {
        _codeController = TextEditingController();
      }
      if (next.correctOrder != null) {
        _draggableItems = List.from(next.correctOrder!)..shuffle();
      }
    });
    // After advancing, check if all clues are completed to update quest status
    final userClues = await clueRepository.getUserQuestClues();
    final allCompleted =
        userClues.every((c) => c.progressStep >= c.steps.length);
    if (allCompleted) {
      final questRepo = QuestRepository();
      await questRepo.updateUserQuestStatus(
          clueRepository.quest.id, QuestStatus.completed);
    }
  }

  void _showHintModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Hints',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_currentStep.hints != null &&
                      _currentStep.hints!.isNotEmpty)
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _currentStep.hints!.length,
                        itemBuilder: (context, index) {
                          final hint = _currentStep.hints![index];
                          return _buildHintCard(hint, setModalState);
                        },
                      ),
                    )
                  else
                    const Text(
                      'No hints available for this step.',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHintCard(Hint hint, StateSetter setModalState) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: hint.isUsed ? null : () => _showHintWarning(hint, setModalState),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hint.preview,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          hint.isUsed ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hint.isUsed
                            ? Colors.green[300]!
                            : Colors.orange[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hint.isUsed ? Icons.add : Icons.timer,
                          size: 16,
                          color: hint.isUsed
                              ? Colors.green[800]
                              : Colors.orange[800],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${hint.minutePenalty} min',
                          style: TextStyle(
                            color: hint.isUsed
                                ? Colors.green[800]
                                : Colors.orange[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hint.isUsed) ...[
                const SizedBox(height: 12),
                Text(
                  hint.text,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showHintWarning(Hint hint, StateSetter setModalState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Are you sure?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 20, color: Colors.black),
              children: [
                const TextSpan(text: 'This hint will add '),
                TextSpan(
                  text: '${hint.minutePenalty} minutes',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' to your quest time.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  hint.isUsed = true;
                });
                setModalState(() {
                  hint.isUsed = true;
                });
                _applyHintPenalty(hint);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              child: const Text(
                'Accept Penalty',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _applyHintPenalty(Hint hint) async {
    await clueRepository.saveHintUsage(
        widget.clue.id, _currentStep.step, hint.id);
    await clueRepository.addPenaltyMinutes(hint.minutePenalty);
    Alert.toast('+${hint.minutePenalty} minute penalty', ToastGravity.TOP);
    hint.isUsed = true;
  }
}
