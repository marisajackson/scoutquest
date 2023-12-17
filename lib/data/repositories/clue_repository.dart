import 'dart:convert';
import 'package:scoutquest/data/json_loader.dart';
import 'package:scoutquest/app/models/clue.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClueRepository {
  final Quest quest;
  ClueRepository(this.quest);

  Future<List<Clue>> getUserQuestClues() async {
    final allClues = await getQuestClues();

    var cluesStatus = await getUserQuestClueStatus();

    cluesStatus ??= await initializeUserQuestClues(allClues);

    cluesStatus = jsonDecode(cluesStatus);
    cluesStatus = Map<String, String>.from(cluesStatus);

    for (var clue in allClues) {
      if (!cluesStatus.containsKey(clue.id)) {
        cluesStatus[clue.id] = ClueStatus.locked.toString();
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('$quest.id-clues', jsonEncode(cluesStatus));
      }

      clue.status = ClueStatus.values.firstWhere(
          (e) => e.toString() == cluesStatus[clue.id],
          orElse: () => ClueStatus.locked);
    }

    return allClues;
  }

  Future<String> initializeUserQuestClues(questClues) async {
    Map<String, String> cluesMap = {};
    for (var clue in questClues) {
      cluesMap[clue.id] = ClueStatus.locked.toString();
    }
    var cluesStatus = jsonEncode(cluesMap);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('${quest.id}-clues', cluesStatus);

    return cluesStatus;
  }

  Future<List<Clue>> getQuestClues() async {
    final clueJSON = await loadJsonFromUrl(quest.clueFile);

    if (clueJSON == null) {
      return [];
    }

    final allClues = clueJSON
        .map((clueJSON) => Clue.fromJson(clueJSON as Map<String, dynamic>))
        .toList();

    return allClues;
  }

  Future verifyClue(String clueID) async {
    final clues = await getQuestClues();

    bool clueExists = clues.any((clue) => clue.code == clueID);

    if (!clueExists) {
      return false;
    }
    return true;
  }

  Future getUserQuestClueStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final cluesStatus = prefs.getString('${quest.id}-clues');
    return cluesStatus;
  }

  Future updateClueStatus(clueID, ClueStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final cluesStatus = prefs.getString('${quest.id}-clues');
    if (cluesStatus == null) {
      Map<String, String> cluesMap = {};
      cluesMap[clueID] = status.toString();
      prefs.setString('${quest.id}-clues', jsonEncode(cluesMap));
      return;
    }
    final cluesJSON = jsonDecode(cluesStatus);
    Map<String, String> cluesMap = Map<String, String>.from(cluesJSON);
    cluesMap[clueID] = ClueStatus.values
        .firstWhere((e) => e == status, orElse: () => ClueStatus.locked)
        .toString();
    prefs.setString('${quest.id}-clues', jsonEncode(cluesMap));
  }
}
