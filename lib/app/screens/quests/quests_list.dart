import 'package:flutter/material.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/utils/functions.dart';

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
            child: quest.billboardImage != null
                ? Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: colorFromHex(quest.billboardBackgroundColor,
                          fallback: Colors.white),
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
                    child: ClipRRect(
                      child: Image.network(
                        quest.billboardImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  )
                : Container(
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
                        Text(quest.billboardImage ?? ""),
                        Image.network(
                          quest.iconImage!,
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.timer_outlined,
                                size: 50, color: Colors.black);
                          },
                        ),
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
