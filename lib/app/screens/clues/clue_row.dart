import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
            Stack(
              children: [
                if (clue.iconImage != null && clue.iconImage!.isNotEmpty) ...[
                  SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: SvgPicture.network(
                        clue.iconImage!,
                        width: 50.0,
                        height: 50.0,
                        colorFilter: clue.status == ClueStatus.completed
                            ? ColorFilter.mode(
                                Colors.grey.shade400, BlendMode.srcIn)
                            : null,
                      )),
                ] else ...[
                  Icon(
                    clue.status != ClueStatus.locked
                        ? (clue.icon != null
                            ? IconUtil.getIconFromString(clue.icon!)
                            : IconUtil.getIconForClueType(clue.type))
                        : Icons.lock,
                    size: 50.0,
                    color: clue.status == ClueStatus.completed
                        ? Colors.grey.shade400
                        : null,
                  ),
                ],
              ],
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          clue.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18.0,
                            decoration: clue.status == ClueStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                            color: clue.status == ClueStatus.completed
                                ? Colors.grey.shade600
                                : null,
                          ),
                        ),
                      ),
                      _buildStatusChip(),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    clue.status != ClueStatus.locked
                        ? clue.getShortText
                        : '???',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w900,
                      color: clue.status == ClueStatus.completed
                          ? Colors.grey.shade600
                          : null,
                    ),
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

  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;
    Color textColor;

    if (clue.status == ClueStatus.unlocked) {
      return const SizedBox.shrink();
    }

    switch (clue.status) {
      case ClueStatus.locked:
        chipColor = Colors.grey.shade300;
        statusText = 'LOCKED';
        textColor = Colors.grey.shade700;
        break;
      case ClueStatus.inProgress:
        chipColor = Colors.yellow.shade100;
        statusText = 'IN PROGRESS';
        textColor = Colors.yellow.shade800;
        break;
      case ClueStatus.completed:
        chipColor = Colors.green.shade100;
        statusText = 'COMPLETED';
        textColor = Colors.green.shade800;
        break;
      default:
        chipColor = Colors.blue.shade100;
        statusText = '';
        textColor = Colors.blue.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
