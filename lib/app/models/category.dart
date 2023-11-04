import 'package:scoutquest/app/models/clue.dart';

class Category {
  final String name;
  bool isExpanded;
  final List<Clue> clues;

  Category(
      {required this.name, this.isExpanded = false, this.clues = const []});
}
