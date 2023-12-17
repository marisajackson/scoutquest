import 'package:scoutquest/app/models/clue.dart';

class ClueCategory {
  final String name;
  bool isExpanded;
  final List<Clue> clues;

  ClueCategory(
      {required this.name, this.isExpanded = false, this.clues = const []});
}
