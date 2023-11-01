import 'dart:async';
import 'package:scoutquest/data/models/quest_model.dart';
import 'package:sqflite/sqflite.dart';

class QuestDatabaseHelper {
  final Database database;

  QuestDatabaseHelper({required this.database});

  Future<void> insertQuest(Quest quest) async {
    await database.insert('quests', quest.toMap());
  }

  Future<List<Quest>> queryQuests() async {
    final List<Map<String, dynamic>> maps = await database.query('quests');

    return List.generate(maps.length, (i) {
      return Quest(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }
}
