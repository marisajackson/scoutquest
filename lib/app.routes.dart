import 'package:flutter/material.dart';
import 'package:scoutquest/app/screens/clues/clues_screen.dart';
import 'package:scoutquest/app/screens/quests/quests_screen.dart';
import 'package:scoutquest/data/models/quest.dart';

const String initialRoute = '/';
const String questsRoute = '/quests';
const String cluesRoute = '/clues';

final routes = {
  initialRoute: (BuildContext context) => const QuestsScreen(),
  questsRoute: (BuildContext context) => const QuestsScreen(),
  cluesRoute: (BuildContext context) {
    final Quest quest = ModalRoute.of(context)!.settings.arguments as Quest;
    return CluesScreen(quest: quest);
  },
};
