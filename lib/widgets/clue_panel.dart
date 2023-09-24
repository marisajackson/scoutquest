import 'package:flutter/material.dart';
import 'package:scoutquest/models/clue_info.dart';

class CluePanel extends StatelessWidget {
  const CluePanel({
    Key? key,
    required this.selectedClue,
    required this.onTap,
  }) : super(key: key);

  final ClueInfo selectedClue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  selectedClue.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                Text(
                  selectedClue.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 16.0),
                if (selectedClue.image != null)
                  Image.asset(
                    selectedClue.image!,
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 16.0),
                if (selectedClue.audio != null)
                  // Add audio player widget or functionality here
                  Text('Audio: ${selectedClue.audio}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
