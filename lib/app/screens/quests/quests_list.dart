import 'package:flutter/material.dart';
import 'package:scoutquest/data/models/quest.dart';

class QuestsList extends StatelessWidget {
  final List<Quest> quests;
  final Future<void> Function() onRefresh;
  final Function(Quest) onChooseQuest;

  const QuestsList({
    super.key,
    required this.quests,
    required this.onRefresh,
    required this.onChooseQuest,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: quests.length,
        itemBuilder: (context, index) {
          final quest = quests[index];
          return GestureDetector(
            // Define the behavior when the item is tapped
            onTap: () {
              onChooseQuest(quest);
              // Handle the onTap action for a quest item
              // You can navigate to the quest details or perform other actions.
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.add_box, // Replace with your quest icon
                    size: 50.0,
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quest.name, // Display quest name
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          'Description: ', // Display quest description
                          style: TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          'Status:', // Display quest status or other information
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
