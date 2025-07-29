import 'package:flutter/material.dart';
import 'package:scoutquest/app/models/quest.dart';

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
            onTap: () {
              onChooseQuest(quest);
            },
            child: Container(
              padding: const EdgeInsets.all(26.0),
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Image.asset(
                  //   'assets/elements/elements_icon.png',
                  //   width: 50,
                  //   height: 50,
                  // ),
                  const Icon(Icons.park, size: 50, color: Colors.black),
                  const SizedBox(width: 30.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          quest.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20.0,
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
