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

    var cluesProgress = await getUserQuestClueProgress();

    cluesProgress ??= await initializeUserQuestClues(allClues);

    cluesProgress = jsonDecode(cluesProgress);
    cluesProgress = Map<String, String>.from(cluesProgress);

    for (var clue in allClues) {
      if (!cluesProgress.containsKey(clue.id)) {
        var questClueStep = quest.clueStep ?? 0;
        cluesProgress[clue.id] = questClueStep.toString();
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('$quest.id-clues', jsonEncode(cluesProgress));
      }

      // if the clue progress is a number, set the progress step
      if (int.tryParse(cluesProgress[clue.id] ?? '') != null) {
        clue.progressStep = int.parse(cluesProgress[clue.id]!);
      } else {
        // map the clue status to the progress step
        clue.progressStep = ClueStatus.values
            .indexWhere((e) => e.toString() == cluesProgress[clue.id]);
        if (clue.progressStep == -1) {
          clue.progressStep = 0;
        }
      }

      if (clue.progressStep < int.parse(quest.clueStep ?? '0')) {
        clue.progressStep = int.parse(quest.clueStep ?? '0');
      }
    }

    return allClues;
  }

  Future<String> initializeUserQuestClues(List<Clue> questClues) async {
    var questClueStep = quest.clueStep ?? 0;
    Map<String, String> cluesMap = {};
    for (var clue in questClues) {
      cluesMap[clue.id] = questClueStep.toString();
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

  Future getUserQuestClueProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final cluesStatus = prefs.getString('${quest.id}-clues');
    return cluesStatus;
  }

  Future updateClueProgress(String clueID, int progressStep) async {
    final prefs = await SharedPreferences.getInstance();
    final cluesStatus = prefs.getString('${quest.id}-clues');
    if (cluesStatus == null) {
      Map<String, String> cluesMap = {};
      cluesMap[clueID] = 0.toString();
      prefs.setString('${quest.id}-clues', jsonEncode(cluesMap));
      return;
    }

    final cluesJSON = jsonDecode(cluesStatus);
    Map<String, String> cluesMap = Map<String, String>.from(cluesJSON);
    cluesMap[clueID] = progressStep.toString();
    prefs.setString('${quest.id}-clues', jsonEncode(cluesMap));

    final clues = await getQuestClues();
    final clue = clues.firstWhere((c) => c.id == clueID);

    if (progressStep >= clue.steps.length) {
      await updateClueStatus(clueID, ClueStatus.completed);
    }
  }

  Future updateClueStatus(String clueID, ClueStatus status) async {
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
