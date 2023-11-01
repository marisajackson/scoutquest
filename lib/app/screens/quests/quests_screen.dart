import 'package:flutter/material.dart';
import 'package:scoutquest/app/screens/quests/quests_empty.dart';
import 'package:scoutquest/app/screens/quests/quests_list.dart';
import 'package:scoutquest/data/models/quest.dart';
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
      Logger.log('Loading quests...');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quests'),
      ),
      body: quests.isEmpty
          ? const QuestsEmpty()
          : QuestsList(
              quests: quests,
              onRefresh: _refreshQuests,
            ),
    );
  }
}
