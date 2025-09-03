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

    final preferences = await SharedPreferences.getInstance();
    final allQuests = questJSON
        .map((questJson) => Quest(
              id: questJson['id'],
              name: questJson['name'],
              clueFile: questJson['clueFile'] ?? '',
              status: QuestStatus.locked,
              clueStep: questJson['clueStep']?.toString() ?? '0',
              welcomeHtml: questJson['welcomeHtml'] ?? '',
              completionHtml: questJson['completionHtml'] ?? '',
              startTime: preferences
                          .getString('${questJson['id']}-startTime') !=
                      null
                  ? DateTime.parse(
                      preferences.getString('${questJson['id']}-startTime')!)
                  : null,
              endTime:
                  preferences.getString('${questJson['id']}-endTime') != null
                      ? DateTime.parse(
                          preferences.getString('${questJson['id']}-endTime')!)
                      : null,
            ))
        .toList();

    for (var quest in allQuests) {
      quest.status = await getUserQuestStatus(quest.id);
      // quest.status = QuestStatus.locked; // TESTING ONLY
    }

    final availableQuests = allQuests.where((quest) {
      return quest.status != QuestStatus.locked;
    }).toList();

    return availableQuests;
  }

  Future<bool> verifyQuest(String questID) async {
    final questJSON = await loadQuestsFromJson();

    if (questJSON == null) {
      return false; // Handle if JSON data is not available
    }

    final quest = questJSON.firstWhere(
        (questJson) => questJson['id'] == questID,
        orElse: () => null);

    if (quest == null) {
      return false; // Handle if quest is not found
    }

    return true;
  }

  Future<QuestStatus> getUserQuestStatus(String questID) async {
    final preferences = await SharedPreferences.getInstance();
    var statusString = preferences.getString(questID);

    return QuestStatus.values.firstWhere((e) => e.toString() == statusString,
        orElse: () => QuestStatus.locked);
  }

  Future<bool> updateUserQuestStatus(String questID, QuestStatus status) async {
    final preferences = await SharedPreferences.getInstance();
    final result = await preferences.setString(questID, status.toString());
    // Save start time when marking quest in progress
    if (status == QuestStatus.inProgress) {
      await preferences.setString(
          '$questID-startTime', DateTime.now().toIso8601String());
    }

    if (status == QuestStatus.completed) {
      await preferences.setString(
          '$questID-endTime', DateTime.now().toIso8601String());
    }
    return result;
  }

  Future<List?> loadQuestsFromJson() async {
    return await loadJsonFromUrl('http://scoutquest.co/quests/quests.json');
  }

  Future<Map<String, dynamic>?> getUserQuest(String questID) async {
    final prefs = await SharedPreferences.getInstance();
    // return status, total duration, penalty amount, duration (without penalty), start time, end time
    final startString = prefs.getString("$questID-startTime");
    final endString = prefs.getString("$questID-endTime");

    Duration? totalDuration;
    Duration? durationWithoutPenalty;
    final penaltyMinutes = prefs.getInt("$questID-penalty") ?? 0;

    if (startString != null) {
      final start = DateTime.parse(startString);
      // Use endTime if available, otherwise use current time
      final end =
          endString != null ? DateTime.parse(endString) : DateTime.now();
      final baseDuration = end.difference(start);
      final penaltyDuration = Duration(minutes: penaltyMinutes);
      totalDuration = baseDuration + penaltyDuration;
      durationWithoutPenalty = baseDuration;
    }

    return {
      'status': prefs.getString(questID),
      'totalDuration': totalDuration?.inSeconds, // Duration in seconds
      'penalty': penaltyMinutes,
      'durationWithoutPenalty':
          durationWithoutPenalty?.inSeconds, // Duration in seconds
      'startTime': startString,
      'endTime': endString,
    };
  }
}
