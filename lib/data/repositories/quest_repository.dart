import 'package:scoutquest/data/json_loader.dart';
import 'package:scoutquest/data/models/quest.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class QuestRepository {
  QuestRepository();

  Future<List<Quest>> getAvailableQuests() async {
    // Load the JSON file containing all quests
    final questJSON =
        await loadQuestsFromJson(); // Implement loading from your JSON file

    if (questJSON == null) {
      return []; // Handle if JSON data is not available
    }

    final allQuests = questJSON
        .map((questJson) => Quest(
              id: questJson['id'],
              name: questJson['name'],
              // Map other quest properties as needed
            ))
        .toList();

    return allQuests;

    // Retrieve quest IDs and their statuses from SharedPreferences
    // final preferences = await SharedPreferences.getInstance();
    // final questStatusMap =
    //     preferences.getKeys().fold<Map<int, int>>({}, (acc, key) {
    //   final id = int.tryParse(key);
    //   if (id != null) {
    //     acc[id] = preferences.getInt(key) ?? 0; // Default status if not found
    //   }
    //   return acc;
    // });

    // // Filter the quests based on the stored IDs and their statuses
    // final availableQuests = allQuests.where((quest) {
    //   final status = questStatusMap[quest.id];
    //   return status != null &&
    //       status > 0; // Change the condition based on your status values
    // }).toList();

    // return availableQuests;
  }

  Future<List?> loadQuestsFromJson() async {
    return await loadJsonFromAsset('assets/quests.json');
  }
}
