import 'package:flutter/material.dart';
import 'package:scoutquest/app.routes.dart';
import 'package:scoutquest/app/screens/quests/quests_empty.dart';
import 'package:scoutquest/app/screens/quests/quests_list.dart';
import 'package:scoutquest/app/models/quest.dart';
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
      Logger.log('Loaded ${questList.length} quests');
      setState(() {
        quests = questList;
      });
    } catch (e) {
      // Handle errors, e.g., display an error message
      Logger.log('Error loading quests: $e');
    }
  }

  Future<void> _refreshQuests() async {
    // Manually trigger a refresh to update the list
    // await _loadQuests();
    Logger.log('refreshing quests');
  }

  // function that chooses a quest
  void _chooseQuest(Quest quest) {
    Logger.log('Quest ${quest.name} chosen');
    // route to clues screen
    Navigator.of(context).pushNamed(cluesRoute, arguments: quest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scout Quest'),
      ),
      body: quests.isEmpty
          ? const QuestsEmpty()
          : QuestsList(
              quests: quests,
              onRefresh: _refreshQuests,
              onChooseQuest: _chooseQuest,
            ),
    );
  }
}
