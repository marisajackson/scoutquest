import 'package:scoutquest/data/models/quest_model.dart';
import 'package:scoutquest/db/quest_database_helper.dart';

class QuestRepository {
  final QuestDatabaseHelper databaseHelper;

  QuestRepository({required this.databaseHelper});

  Future<void> insertQuest(Quest quest) async {
    await databaseHelper.insertQuest(quest);
  }

  Future<List<Quest>> getQuests() async {
    // Additional logic here, such as data transformation or caching
    final quests = await databaseHelper.queryQuests();
    return quests;
  }
}
