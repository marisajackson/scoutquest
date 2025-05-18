import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:scoutquest/app/models/clue.dart';
import 'package:scoutquest/app/widgets/audio_player.dart';
import 'package:scoutquest/data/repositories/clue_repository.dart';
import 'package:scoutquest/utils/constants.dart';

class CluePanel extends StatefulWidget {
  const CluePanel({
    Key? key,
    required this.selectedClue,
    required this.onTap,
    required this.clueRepository,
  }) : super(key: key);

  final Clue selectedClue;
  final VoidCallback onTap;
  final ClueRepository clueRepository;

  @override
  CluePanelState createState() => CluePanelState();
}

class CluePanelState extends State<CluePanel> {
  bool secretCodeIncorrect = false;
  final TextEditingController _secretCodeController = TextEditingController();

  late List<String> _draggableItems;
  @override
  void initState() {
    super.initState();
    if (widget.selectedClue.correctOrder == null ||
        widget.selectedClue.correctOrder!.isEmpty) {
      return;
    }
    _draggableItems = List.from(widget.selectedClue.correctOrder!)..shuffle();
  }

  void submitSecretCode() {
    final secretCodeGuess = _secretCodeController.text.toLowerCase();

    if (secretCodeGuess != widget.selectedClue.secretCode) {
      setState(() {
        secretCodeIncorrect = true;
      });
      _secretCodeController.clear();
      return;
    }

    widget.clueRepository
        .updateClueStatus(widget.selectedClue.id, ClueStatus.unlocked);

    setState(() {
      widget.selectedClue.status = ClueStatus.unlocked;
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _draggableItems.removeAt(oldIndex);
      _draggableItems.insert(newIndex, item);
    });
  }

  void _submitOrder() {
    final correct = widget.selectedClue.correctOrder!;
    if (listEquals(_draggableItems, correct)) {
      widget.clueRepository
          .updateClueStatus(widget.selectedClue.id, ClueStatus.unlocked);
      setState(() => widget.selectedClue.status = ClueStatus.unlocked);
      print('UNLOCKED!');
    } else {
      print('Incorrect order');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDrag = widget.selectedClue.correctOrder != null &&
        widget.selectedClue.correctOrder!.isNotEmpty;

    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    return ConstrainedBox(
      constraints: BoxConstraints(
        // The sheet will grow to fit its content,
        // but never beyond 80% of screen height.
        maxHeight: maxHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ——————— Drag Handle ———————
          Container(
            width: 70,
            height: 4,
            margin: const EdgeInsets.fromLTRB(0, 16, 0, 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ————— Scrollable Content —————
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.selectedClue.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  Html(
                    data:
                        "<div style='text-align: center; font-size: 18px; font-weight: bold;'>${widget.selectedClue.displayText}</div>",
                  ),
                  const SizedBox(height: 16.0),
                  if (widget.selectedClue.hasSecret &&
                      !widget.selectedClue.isUnlocked)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: _secretCodeController,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: defaultInputDecoration.copyWith(
                              labelText: 'Enter Secret Code',
                            ),
                            onChanged: (value) {
                              setState(() {
                                secretCodeIncorrect = false;
                              });
                            },
                          ),
                        ),
                        if (secretCodeIncorrect)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Incorrect secret code',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 8.0),
                          ),
                          onPressed: () =>
                              submitSecretCode(), // Pass the secret code to the callback
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (widget.selectedClue.image != null)
                    Image.network(
                      widget.selectedClue.displayImage!,
                      height: 200.0,
                      fit: BoxFit.cover,
                    ),
                  if (widget.selectedClue.audio != null)
                    AudioControlWidget(audioAsset: widget.selectedClue.audio!),
                  const SizedBox(height: 40.0),
                  if (hasDrag) ...[
                    ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onReorder: _onReorder,
                      buildDefaultDragHandles: false,
                      proxyDecorator: (child, index, animation) {
                        return FadeTransition(
                          opacity: animation.drive(Tween(begin: 0.8, end: 1.0)),
                          child: Material(
                            type: MaterialType.transparency,
                            child: child,
                          ),
                        );
                      },
                      children: [
                        for (int index = 0;
                            index < _draggableItems.length;
                            index++)
                          Align(
                            key: ValueKey(_draggableItems[index]),
                            alignment: Alignment.center,
                            widthFactor: 1.0, // ✏️ only as wide as its child
                            child: ReorderableDragStartListener(
                              index: index,
                              child:
                                  _buildItemBox(_draggableItems[index], index),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _submitOrder,
                      child: const Text(
                        'Submit Order',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

Widget _buildItemBox(String text, int index) {
  return Container(
    width: 250,
    margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade400),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.drag_indicator, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
