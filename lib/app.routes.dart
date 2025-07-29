import 'package:flutter/material.dart';
import 'package:scoutquest/app/screens/clues/clues_screen.dart';
import 'package:scoutquest/app/screens/quests/quest_scoreboard.dart';
import 'package:scoutquest/app/screens/quests/quests_screen.dart';
import 'package:scoutquest/app/screens/quests/quests_start.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/app/screens/splash_screen.dart';
import 'package:scoutquest/app/screens/quests/quest_complete.dart';

const String initialRoute = '/';
const String questsRoute = '/quests';
const String questsStartRoute = '/quests/start';
const String cluesRoute = '/clues';
const String questCompleteRoute = '/quests/complete';
const String questScoreboardRoute = '/quests/scoreboard';

final routes = {
  initialRoute: (BuildContext context) => const SplashScreen(),
  questsRoute: (BuildContext context) => const QuestsScreen(),
  questsStartRoute: (BuildContext context) {
    final Quest quest = ModalRoute.of(context)!.settings.arguments as Quest;
    return QuestsStart(quest: quest);
  },
  cluesRoute: (BuildContext context) {
    final Quest quest = ModalRoute.of(context)!.settings.arguments as Quest;
    return CluesScreen(quest: quest);
  },
  questCompleteRoute: (BuildContext context) {
    final Quest quest = ModalRoute.of(context)!.settings.arguments as Quest;
    return QuestComplete(quest: quest);
  },
  questScoreboardRoute: (BuildContext context) {
    final Quest quest = ModalRoute.of(context)!.settings.arguments as Quest;
    return QuestScoreboard(quest: quest);
  },
};
