import 'dart:convert';
import 'package:scoutquest/data/json_loader.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/data/repositories/score_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestRepository {
  final ScoreRepository _scoreRepository = ScoreRepository();

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
              iconImage: questJson['iconImage'] ?? '',
              tipsHtml: questJson['tipsHtml'] ?? '',
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
              billboardImage: questJson['billboardImage'],
              billboardBackgroundColor:
                  questJson['billboardBackgroundColor'] ?? 'ffffff',
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

      // Check if score has already been presubmitted
      final existingDocId = preferences.getString('$questID-scoreDocId');

      if (existingDocId == null) {
        // Presubmit score data only if not already done
        try {
          final questData = await getQuestSubmissionData(questID);
          if (questData != null) {
            final duration =
                Duration(minutes: questData['totalDurationMinutes']);
            final documentId = await _scoreRepository.presubmitScore(
              questId: questID,
              duration: duration,
              questData: questData,
            );

            // Store the document ID for later update
            await preferences.setString('$questID-scoreDocId', documentId);
          }
        } catch (e) {
          // Log error but don't prevent quest completion
          print('Failed to presubmit score: $e');
        }
      }
    }
    return result;
  }

  // Get the presubmitted score document ID
  Future<String?> getPresubmittedScoreDocId(String questID) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('$questID-scoreDocId');
  }

  Future<List?> loadQuestsFromJson() async {
    return await loadJsonFromUrl('https://scoutquest.co/quests/quests.json');
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

  Future<Quest> refreshQuest(Quest quest) async {
    final prefs = await SharedPreferences.getInstance();
    final startString = prefs.getString("${quest.id}-startTime");
    final endString = prefs.getString("${quest.id}-endTime");

    return Quest(
      id: quest.id,
      name: quest.name,
      clueFile: quest.clueFile,
      status: await getUserQuestStatus(quest.id),
      clueStep: quest.clueStep,
      welcomeHtml: quest.welcomeHtml,
      completionHtml: quest.completionHtml,
      startTime: startString != null ? DateTime.parse(startString) : null,
      endTime: endString != null ? DateTime.parse(endString) : null,
      iconImage: quest.iconImage,
      tipsHtml: quest.tipsHtml,
    );
  }

  Future<Map<String, dynamic>?> getQuestSubmissionData(String questID) async {
    final prefs = await SharedPreferences.getInstance();
    final startString = prefs.getString("$questID-startTime");
    final endString = prefs.getString("$questID-endTime");

    if (startString == null || endString == null) return null;

    final start = DateTime.parse(startString);
    final end = DateTime.parse(endString);
    final baseDuration = end.difference(start);
    final penaltyMinutes = prefs.getInt("$questID-penalty") ?? 0;
    final totalDuration = baseDuration + Duration(minutes: penaltyMinutes);

    // Get hint usage data
    final hintsStatus = prefs.getString('$questID-hints') ?? '{}';
    final hintsUsage = Map<String, List<dynamic>>.from(jsonDecode(hintsStatus));

    final questInfo = {
      'questId': questID,
      'startTime': startString,
      'endTime': endString,
      'baseDurationMinutes': baseDuration.inMinutes,
      'penaltyMinutes': penaltyMinutes,
      'totalDurationMinutes': totalDuration.inMinutes,
      'hintsUsage': hintsUsage,
      'submittedAt': DateTime.now().toIso8601String(),
    };

    return questInfo;
  }
}
