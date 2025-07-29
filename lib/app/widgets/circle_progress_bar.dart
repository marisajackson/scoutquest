import 'package:flutter/material.dart';
import 'package:scoutquest/utils/constants.dart';

class CircleProgressBar extends StatelessWidget {
  final double count;
  final int total;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;
  final TextStyle textStyle;

  const CircleProgressBar({
    super.key,
    required this.count,
    required this.total,
    this.progressColor = ScoutQuestColors.primaryAction,
    this.backgroundColor = Colors.grey,
    this.strokeWidth = 3.5,
    this.textStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final progress = total != 0 ? count / total : 0.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.scale(
          scale: 1.75,
          child: CircularProgressIndicator(
            value: progress,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            strokeWidth: strokeWidth,
          ),
        ),
        Text(
          '${((count / total) * 100).toStringAsFixed(0)}%',
          style: textStyle,
        ),
      ],
    );
  }
}
