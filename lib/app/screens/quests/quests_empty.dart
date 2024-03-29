import 'package:flutter/material.dart';
import 'package:scoutquest/utils/constants.dart';

class QuestsEmpty extends StatelessWidget {
  const QuestsEmpty({
    Key? key,
    required this.onAddQuest,
  }) : super(key: key);

  final VoidCallback? onAddQuest;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_circle,
            size: 100.0,
            color: Colors.grey,
          ),
          const Text(
            'No quests available',
            style: TextStyle(
                fontSize: 18.0, color: ScoutQuestColors.secondaryText),
          ),
          const SizedBox(height: 20.0),
          FloatingActionButton.extended(
              onPressed: onAddQuest, label: const Text('Add Quest')),
        ],
      ),
    );
  }
}
