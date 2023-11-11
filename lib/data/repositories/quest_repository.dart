import 'package:scoutquest/data/json_loader.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestRepository {
  QuestRepository();

  Future<List<Quest>> getAvailableQuests() async {
    final questJSON = await loadQuestsFromJson();

    if (questJSON == null) {
      return []; // Handle if JSON data is not available
    }

    final allQuests = questJSON
        .map((questJson) => Quest(
            id: questJson['id'],
            name: questJson['name'],
            clueFile: questJson['clueFile'] ?? '',
            status: QuestStatus.locked))
        .toList();

    for (var quest in allQuests) {
      quest.status = await getUserQuestStatus(quest.id);
    }

    final availableQuests = allQuests.where((quest) {
      return quest.status != QuestStatus.locked;
    }).toList();

    return availableQuests;
  }

  Future<QuestStatus> getUserQuestStatus(String questID) async {
    final preferences = await SharedPreferences.getInstance();
    var statusString = preferences.getString(questID);

    return QuestStatus.values.firstWhere(
        (e) => e.toString() == 'QuestStatus.$statusString',
        orElse: () => QuestStatus.locked);
  }

  Future<bool> updateUserQuestStatus(String questID, QuestStatus status) async {
    final preferences = await SharedPreferences.getInstance();
    return await preferences.setString(questID, status.toString());
  }

  Future<List?> loadQuestsFromJson() async {
    return await loadJsonFromAsset('assets/quests.json');
  }
}
