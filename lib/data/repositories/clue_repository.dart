import 'dart:convert';
import 'package:scoutquest/data/json_loader.dart';
import 'package:scoutquest/data/models/clue.dart';
import 'package:scoutquest/data/models/quest.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClueRepository {
  final Quest quest;
  ClueRepository(this.quest);

  Future<List<Clue>> getUserQuestClues() async {
    final allClues = await getQuestClues();

    var cluesStatus = await getUserQuestClueStatus();

    cluesStatus ??= await initializeUserQuestClues(allClues);

    cluesStatus = jsonDecode(cluesStatus);
    cluesStatus = Map<String, bool>.from(cluesStatus);

    for (var clue in allClues) {
      if (!cluesStatus.containsKey(clue.id)) {
        cluesStatus[clue.id] = false;
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('$quest.id-clues', jsonEncode(cluesStatus));
      }

      clue.isUnlocked = cluesStatus[clue.id];
    }

    return allClues;
  }

  Future<String> initializeUserQuestClues(questClues) async {
    Map<String, bool> cluesMap = {};
    for (var clue in questClues) {
      cluesMap[clue.id] = false;
    }
    var cluesStatus = jsonEncode(cluesMap);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('${quest.id}-clues', cluesStatus);

    return cluesStatus;
  }

  Future<List<Clue>> getQuestClues() async {
    // Load the JSON file containing all quests
    final clueJSON = await loadJsonFromAsset(quest.clueFile);

    if (clueJSON == null) {
      return [];
    }

    final allClues = clueJSON
        .map((clueJSON) => Clue.fromJson(clueJSON as Map<String, dynamic>))
        .toList();

    return allClues;
  }

  Future getUserQuestClueStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final cluesStatus = prefs.getString('${quest.id}-clues');
    return cluesStatus;
  }

  Future unlockUserClue(clueID) async {
    final prefs = await SharedPreferences.getInstance();
    final cluesStatus = prefs.getString('${quest.id}-clues');
    if (cluesStatus == null) {
      Map<String, bool> cluesMap = {};
      cluesMap[clueID] = true;
      prefs.setString('${quest.id}-clues', jsonEncode(cluesMap));
      return;
    }
    Map<String, bool> cluesMap = jsonDecode(cluesStatus);
    cluesMap[clueID] = true;
    prefs.setString('${quest.id}-clues', jsonEncode(cluesMap));
  }
}
