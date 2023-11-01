import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoutquest/app/screens/quests/quests_screen.dart';
import 'package:scoutquest/data/repositories/quest_repository.dart';
import 'package:scoutquest/db/quest_database_helper.dart';
import 'package:scoutquest/services/auth_service.dart';
import 'package:scoutquest/config/firebase_options.dart';
import 'package:scoutquest/app/screens/auth/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:scoutquest/services/data_sync_service.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize the SQLite database
  final database = await openDatabase('your_database.db');
  final databaseHelper = QuestDatabaseHelper(database: database);
  final questRepository = QuestRepository(databaseHelper: databaseHelper);

  // Create a DataSyncService and pass the database helper
  final dataSyncService = DataSyncService(databaseHelper: databaseHelper);

  runApp(
    Core(
      questRepository: questRepository,
      dataSyncService: dataSyncService, // Pass the data sync service
    ),
  );
}

class Core extends StatelessWidget {
  final QuestRepository questRepository;
  final DataSyncService dataSyncService;

  const Core(
      {Key? key, required this.questRepository, required this.dataSyncService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: Lava(
        questRepository: questRepository,
        dataSyncService: dataSyncService, // Pass the data sync service
      ),
    );
  }
}

class Lava extends StatelessWidget {
  final QuestRepository questRepository;
  final DataSyncService dataSyncService;

  const Lava(
      {Key? key, required this.questRepository, required this.dataSyncService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user != null) {
      // Synchronize the database when a new user is available and not null.
      dataSyncService.synchronizeQuestsFromFirebaseToSQLite(user);
    }

    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: 'Scout Quest',
        home: user == null
            ? const AuthScreen()
            : QuestsScreen(questRepository: questRepository),
      ),
    );
  }
}
