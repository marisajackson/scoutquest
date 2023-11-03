import 'package:scoutquest/data/json_loader.dart';
import 'package:scoutquest/data/models/clue.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClueRepository {
  ClueRepository();

  Future<List<Clue>> getQuestClues(jsonFile) async {
    // Load the JSON file containing all quests
    final clueJSON = await loadQuestCluesFromJson(jsonFile);

    if (clueJSON == null) {
      return []; // Handle if JSON data is not available
    }

    final allClues = clueJSON
        .map((clueJson) => Clue.fromJson(clueJson as Map<String, dynamic>))
        .toList();

    return allClues;
  }

  Future<List?> loadQuestCluesFromJson(clueJson) async {
    return await loadJsonFromAsset(clueJson);
  }

  Future getUserQuestClueStatus(questID) async {
    final prefs = await SharedPreferences.getInstance();
    final clueStatus = prefs.getString('$questID-clues');
    return clueStatus;
  }
}
