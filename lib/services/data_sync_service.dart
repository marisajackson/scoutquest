import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoutquest/data/models/quest_model.dart';
import 'package:scoutquest/db/quest_database_helper.dart';
import 'package:sqflite/sqflite.dart';

class DataSyncService {
  Future<void> synchronizeQuestsFromFirebaseToSQLite() async {
    final firestore = FirebaseFirestore.instance;
    final database = await openDatabase('your_database.db');
    final questCollection = firestore.collection('quests');
    final querySnapshot = await questCollection.get();
    final questDatabaseHelper = QuestDatabaseHelper(database: database);

    for (var doc in querySnapshot.docs) {
      final quest = Quest(
        id: doc.id,
        name: doc.data()['name'],
      );
      questDatabaseHelper.insertQuest(quest);
    }

    await database.close();
  }

  // Add more synchronization functions as needed for your app.
}
