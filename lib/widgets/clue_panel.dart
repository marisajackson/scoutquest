import 'package:flutter/material.dart';
import 'package:scoutquest/models/clue_info.dart';

class CluePanel extends StatelessWidget {
  const CluePanel({
    Key? key,
    this.selectedClue,
    required this.onTap,
  }) : super(key: key);

  final ClueInfo? selectedClue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (selectedClue != null)
            Text(
              selectedClue!.label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
          if (selectedClue != null)
            Text(
              selectedClue!.text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          const SizedBox(height: 16.0),
          if (selectedClue != null && selectedClue!.image != null)
            Image.asset(
              selectedClue!.image!,
              height: 200.0,
              fit: BoxFit.cover,
            ),
          const SizedBox(height: 16.0),
          if (selectedClue != null && selectedClue!.audio != null)
            // Add audio player widget or functionality here
            Text('Audio: ${selectedClue!.audio}'),
        ],
      ),
    );
  }
}
