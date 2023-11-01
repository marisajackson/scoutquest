import 'package:flutter/material.dart';
import 'package:scoutquest/app/screens/quests/quests_screen.dart';
import 'package:scoutquest/data/repositories/quest_repository.dart';
import 'package:scoutquest/db/quest_database_helper.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the SQLite database
  final database = await openDatabase('your_database.db');
  final databaseHelper = QuestDatabaseHelper(database: database);
  final questRepository = QuestRepository(databaseHelper: databaseHelper);

  // Create a DataSyncService and pass the database helper

  runApp(
    Core(
      questRepository: questRepository,
    ),
  );
}

class Core extends StatelessWidget {
  final QuestRepository questRepository;

  const Core({Key? key, required this.questRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Lava(
      questRepository: questRepository,
    );
  }
}

class Lava extends StatelessWidget {
  final QuestRepository questRepository;

  const Lava({Key? key, required this.questRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scout Quest',
      home: QuestsScreen(questRepository: questRepository),
    );
  }
}
