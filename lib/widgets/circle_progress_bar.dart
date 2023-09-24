import 'package:flutter/material.dart';

class CircleProgressBar extends StatelessWidget {
  final int count;
  final int total;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;
  final TextStyle textStyle;

  const CircleProgressBar({
    Key? key,
    required this.count,
    required this.total,
    this.progressColor = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.strokeWidth = 2.0,
    this.textStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  }) : super(key: key);

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
          '$count/$total',
          style: textStyle,
        ),
      ],
    );
  }
}
