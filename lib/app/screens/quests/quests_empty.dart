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
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 20.0), // Better padding for text
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              size: 100.0,
              color: Colors.grey,
            ),
            const Text(
              'Welcome to Scout Quest! \n\n'
              'Ready for adventure? \n'
              'Visit scoutquest.co to find a quest near you and unlock the full potential of this app!',
              textAlign: TextAlign
                  .center, // Center-aligned text for better readability
              style: TextStyle(
                fontSize: 18.0,
                color: ScoutQuestColors.secondaryText,
              ),
            ),
            const SizedBox(height: 20.0),
            FloatingActionButton.extended(
              onPressed: onAddQuest,
              label: const Text('Add Quest'),
            ),
          ],
        ),
      ),
    );
  }
}
