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
  late final List<String> _draggableItems;

  @override
  void initState() {
    super.initState();
    if (widget.selectedClue.correctOrder != null &&
        widget.selectedClue.correctOrder!.isNotEmpty) {
      _draggableItems = List.from(widget.selectedClue.correctOrder!)..shuffle();
    }
  }

  void _submitSecretCode() {
    final guess = _secretCodeController.text.toLowerCase();
    if (guess != widget.selectedClue.secretCode) {
      setState(() => secretCodeIncorrect = true);
      _secretCodeController.clear();
      return;
    }

    widget.clueRepository
        .updateClueStatus(widget.selectedClue.id, ClueStatus.unlocked);
    setState(() => widget.selectedClue.status = ClueStatus.unlocked);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _draggableItems.removeAt(oldIndex);
      _draggableItems.insert(newIndex, item);
    });
  }

  void _submitOrder() {
    if (listEquals(_draggableItems, widget.selectedClue.correctOrder)) {
      widget.clueRepository
          .updateClueStatus(widget.selectedClue.id, ClueStatus.unlocked);
      setState(() => widget.selectedClue.status = ClueStatus.unlocked);
      print('Unlocked');
    } else {
      // you could swap print() for Alert.toastBottom or similar
      print('Incorrect order');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDrag = widget.selectedClue.correctOrder != null &&
        widget.selectedClue.correctOrder!.isNotEmpty;
    final maxHeight = MediaQuery.of(context).size.height * 0.8;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLabel(),
                  const SizedBox(height: 12),
                  _buildDescription(),
                  const SizedBox(height: 16),
                  if (widget.selectedClue.hasSecret &&
                      !widget.selectedClue.isUnlocked)
                    _buildSecretCodeEntry(),
                  _buildMedia(),
                  if (hasDrag) _buildDragSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() => Container(
        width: 70,
        height: 4,
        margin: const EdgeInsets.fromLTRB(0, 16, 0, 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildLabel() => Text(
        widget.selectedClue.label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
        textAlign: TextAlign.center,
      );

  Widget _buildDescription() => Html(
        data:
            "<div style='text-align: center; font-size: 18px; font-weight: bold;'>${widget.selectedClue.displayText}</div>",
      );

  Widget _buildSecretCodeEntry() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _secretCodeController,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            decoration:
                defaultInputDecoration.copyWith(labelText: 'Enter Secret Code'),
            onChanged: (_) => setState(() => secretCodeIncorrect = false),
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
                  fontSize: 18.0),
            ),
          ),
        const SizedBox(height: 8.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0)),
          onPressed: _submitSecretCode,
          child: const Text('Submit',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget _buildMedia() {
    return Column(
      children: [
        if (widget.selectedClue.image != null)
          Image.network(widget.selectedClue.displayImage!,
              height: 200.0, fit: BoxFit.cover),
        if (widget.selectedClue.audio != null)
          AudioControlWidget(audioAsset: widget.selectedClue.audio!),
        const SizedBox(height: 40.0),
      ],
    );
  }

  Widget _buildDragSection() {
    return Column(
      children: [
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: _onReorder,
          buildDefaultDragHandles: false,
          proxyDecorator: (child, index, animation) => FadeTransition(
            opacity: animation.drive(Tween(begin: 0.8, end: 1.0)),
            child: Material(type: MaterialType.transparency, child: child),
          ),
          children: [
            for (int i = 0; i < _draggableItems.length; i++)
              Align(
                key: ValueKey(_draggableItems[i]),
                alignment: Alignment.center,
                widthFactor: 1.0,
                child: ReorderableDragStartListener(
                  index: i,
                  child: _buildItemBox(_draggableItems[i]),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0)),
          onPressed: _submitOrder,
          child: const Text('Submit',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildItemBox(String text) {
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
          const Icon(Icons.drag_indicator, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
