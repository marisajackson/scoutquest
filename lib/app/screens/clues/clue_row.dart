import 'package:flutter/material.dart';
import 'package:scoutquest/app/models/clue.dart';
import 'package:scoutquest/app/widgets/icon.dart';

class ClueRow extends StatelessWidget {
  final Clue clue;
  final VoidCallback onTap;

  const ClueRow({
    Key? key,
    required this.clue,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              clue.isUnlocked
                  ? IconUtil.getIconForClueType(clue.type)
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
                  Text(
                    clue.isFound ? clue.type : '???',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
