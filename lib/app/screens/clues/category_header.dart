import 'package:flutter/material.dart';
import 'package:scoutquest/app/models/clue.dart';
import 'package:scoutquest/app/models/clue_category.dart';
import 'package:scoutquest/app/widgets/circle_progress_bar.dart';

class CategoryHeader extends StatelessWidget {
  final ClueCategory category;
  final bool isExpanded;

  const CategoryHeader({
    super.key,
    required this.category,
    this.isExpanded = false,
  });

  double calculateProgress(List<Clue> clues) {
    // progress is number of completed clues / total clues.
    double progress = 0;
    for (var clue in clues) {
      if (clue.status == ClueStatus.completed) {
        progress += 1;
      }
    }

    return progress;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          CircleProgressBar(
            count: calculateProgress(category.clues),
            total: category.clues.length,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 30.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.name,
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
    );
  }
}
