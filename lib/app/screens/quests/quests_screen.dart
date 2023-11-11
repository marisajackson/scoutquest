import 'package:flutter/material.dart';
import 'package:scoutquest/app.routes.dart';
import 'package:scoutquest/app/screens/quests/quests_empty.dart';
import 'package:scoutquest/app/screens/quests/quests_list.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/app/widgets/app_bar_manager.dart';
import 'package:scoutquest/app/widgets/qr_scanner.dart';
import 'package:scoutquest/data/repositories/quest_repository.dart';
import 'package:scoutquest/utils/logger.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  QuestsScreenState createState() => QuestsScreenState();
}

class QuestsScreenState extends State<QuestsScreen> {
  final QuestRepository questRepository = QuestRepository();
  List<Quest> quests = [];

  @override
  void initState() {
    super.initState();
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    try {
      final questList = await questRepository.getAvailableQuests();
      setState(() {
        quests = questList;
      });
    } catch (e) {
      // Handle errors, e.g., display an error message
      Logger.log('Error loading quests: $e');
    }
  }

  void addQuest() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return QRScanner(
          title: 'Add Clue',
          description: 'Scan the QR Code',
          onQRCodeScanned: processQRCodeQuest,
        );
      },
    );

    // if in debug mode, add a clue automatically
    // if (kDebugMode) {
    //   unlockClue('FireClue1-4CX6TZPA');
    // }
  }

  void processQRCodeQuest(String? scanResult) {
    Logger.log('QR Code Scanned $scanResult');
    if (scanResult == null) {
      return;
    }

    // sample scan value = "http://scoutquest.co/quests/quest_element_2023.html"
    RegExp regExp = RegExp(r'\/([A-Za-z0-9-]+)\.html');
    Match? match = regExp.firstMatch(scanResult);

    // TODO: If it doesn't have a clue prefix, throw error

    if (match != null) {
      String questCode = match.group(1)!;
      Logger.log(questCode); // 'quest_element_2023'
      unlockQuest(questCode);
    } else {
      Logger.log('No match found.');
    }
  }

  Future<void> unlockQuest(String code) async {
    questRepository.updateUserQuestStatus(code, QuestStatus.unlocked);
    await _loadQuests();
  }

  void _chooseQuest(Quest quest) {
    // route to clues screen
    Navigator.of(context).pushNamed(cluesRoute, arguments: quest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarManager(
        appBar: AppBar(),
      ),
      body: quests.isEmpty
          ? QuestsEmpty(onAddQuest: addQuest)
          : QuestsList(
              quests: quests,
              onRefresh: _loadQuests,
              onChooseQuest: _chooseQuest,
            ),
      floatingActionButton: quests.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                // Handle the action when the button is pressed
                // You can add your code to open a bottom sheet or any other action here
                addQuest();
              },
              label: const Text(
                "Add Quest",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18.0,
                ),
              ), // Change the button label // Add an optional icon
            )
          : null,
    );
  }
}
