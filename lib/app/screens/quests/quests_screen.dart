import 'package:flutter/material.dart';
import 'package:scoutquest/app.routes.dart';
import 'package:scoutquest/app/screens/quests/quests_empty.dart';
import 'package:scoutquest/app/screens/quests/quests_list.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/app/widgets/app_bar_manager.dart';
import 'package:scoutquest/app/widgets/qr_scanner.dart';
import 'package:scoutquest/data/repositories/quest_repository.dart';
import 'package:scoutquest/utils/alert.dart';
import 'package:scoutquest/utils/logger.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  QuestsScreenState createState() => QuestsScreenState();
}

class QuestsScreenState extends State<QuestsScreen> {
  final QuestRepository questRepository = QuestRepository();
  List<Quest> quests = [];
  bool isBottomSheetOpen = false;

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
    // processQRCodeQuest(
    //     'http://scoutquest.co/quests/quest_bicentennial_P2TTzMcei.html');
    setState(() => isBottomSheetOpen = true);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return QRScanner(
          title: 'Add Quest',
          description: 'Scan the Quest QR Code',
          onQRCodeScanned: processQRCodeQuest,
        );
      },
    ).then((_) => {setState(() => isBottomSheetOpen = false)});
  }

  Future<void> processQRCodeQuest(String? scanResult) async {
    if (scanResult == null) {
      return;
    }

    if (isBottomSheetOpen) {
      Navigator.of(context).pop();
    }

    if (!scanResult.contains("/quests/")) {
      Alert.toastBottom('Invalid QR Code.');
      return;
    }

    // regex to extract quest code: quest_element_2023 from 'http://scoutquest.co/quests/quest_element_2023.html'
    RegExp regExp = RegExp(r'\/([^/]+)\.html');
    Match? match = regExp.firstMatch(scanResult);

    if (match != null) {
      String questCode = match.group(1)!;
      final questExists = await questRepository.verifyQuest(questCode);

      if (!questExists) {
        Alert.toastBottom('Invalid QR Code.');
        return;
      }

      await questRepository.updateUserQuestStatus(
          questCode, QuestStatus.unlocked);
      await _loadQuests();
    } else {
      Alert.toastBottom('Invalid QR Code.');
      return;
    }
  }

  void _chooseQuest(Quest quest) {
    if (quest.status == QuestStatus.unlocked) {
      Navigator.of(context).pushNamed(questsStartRoute, arguments: quest);
      return;
    }

    if (quest.status == QuestStatus.inProgress) {
      Navigator.of(context).pushNamed(cluesRoute, arguments: quest);
      return;
    }

    if (quest.status == QuestStatus.completed) {
      Navigator.of(context).pushNamed(questCompleteRoute, arguments: quest);
      return;
    }
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
