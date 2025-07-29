import 'package:flutter/material.dart';
import 'package:scoutquest/app/models/clue.dart';
import 'package:scoutquest/app/widgets/icon.dart';

class ClueRow extends StatelessWidget {
  final Clue clue;
  final VoidCallback onTap;

  const ClueRow({
    super.key,
    required this.clue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              clue.isUnlocked
                  ? clue.icon != null
                      ? IconUtil.getIconFromString(clue.icon!)
                      : IconUtil.getIconForClueType(clue.type)
                  : Icons.lock,
              size: 50.0,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clue.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    clue.isFound ? clue.getShortText : '???',
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
