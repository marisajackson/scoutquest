import 'package:flutter/material.dart';
import 'package:scoutquest/data/models/quest_model.dart';
import 'package:scoutquest/data/repositories/quest_repository.dart';

class QuestsScreen extends StatefulWidget {
  final QuestRepository questRepository;

  const QuestsScreen({super.key, required this.questRepository});

  @override
  QuestsScreenState createState() => QuestsScreenState();
}

class QuestsScreenState extends State<QuestsScreen> {
  List<Quest> quests = [];

  @override
  void initState() {
    super.initState();
    // Load quests when the screen is loaded
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    try {
      // Fetch the list of quests from the repository
      final questList = await widget.questRepository.getQuests();
      setState(() {
        quests = questList;
      });
    } catch (e) {
      // Handle errors, e.g., display an error message
      print('Error loading quests: $e');
    }
  }

  Future<void> _refreshQuests() async {
    // Manually trigger a refresh to update the list
    await _loadQuests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quests'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshQuests,
        child: ListView.builder(
          itemCount: quests.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(quests[index].name),
              // Add more quest information here
            );
          },
        ),
      ),
    );
  }
}
