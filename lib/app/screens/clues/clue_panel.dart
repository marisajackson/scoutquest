import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scoutquest/app/models/clue.dart';
import 'package:scoutquest/data/repositories/clue_repository.dart';
import 'package:scoutquest/data/repositories/quest_repository.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/utils/alert.dart';
import 'package:scoutquest/utils/constants.dart';

/// A panel that walks through each step defined in Clue.steps
class CluePanel extends StatefulWidget {
  final Clue clue;
  final VoidCallback onTap;
  final ClueRepository clueRepository;

  const CluePanel({
    super.key,
    required this.clue,
    required this.onTap,
    required this.clueRepository,
  });

  @override
  CluePanelState createState() => CluePanelState();
}

class CluePanelState extends State<CluePanel> {
  TextEditingController? _codeController;
  List<String>? _draggableItems;
  bool secretCodeIncorrect = false;
  ClueStep get _currentStep => widget.clue.steps.firstWhere(
        (s) => s.step == widget.clue.progressStep,
        orElse: () => widget.clue.steps.first,
      );

  @override
  void initState() {
    super.initState();

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
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.8;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          Text(widget.clue.label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  16, 16, 16, MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildStepContent(_currentStep),
                  if (widget.clue.status == ClueStatus.completed)
                    ElevatedButton(
                      onPressed: widget.onTap,
                      child: const Text('Back to Quest',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHandle() => Container(
        width: 70,
        height: 4,
        margin: const EdgeInsets.only(top: 16, bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(2),
        ),
      );

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
      widget.clueRepository.updateClueProgress(
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
    final userClues = await widget.clueRepository.getUserQuestClues();
    final allCompleted =
        userClues.every((c) => c.progressStep >= c.steps.length);
    if (allCompleted) {
      final questRepo = QuestRepository();
      await questRepo.updateUserQuestStatus(
          widget.clueRepository.quest.id, QuestStatus.completed);
    }
  }
}
