import 'dart:async';
import 'package:flutter/material.dart';
import 'package:scoutquest/app.routes.dart';
import 'package:scoutquest/app/models/clue_category.dart';
import 'package:scoutquest/app/screens/clues/category_header.dart';
import 'package:scoutquest/app/widgets/app_bar_manager.dart';
import 'package:scoutquest/app/widgets/qr_scanner.dart';
import 'package:scoutquest/app/models/clue.dart';
import 'package:scoutquest/app/screens/clues/clue_row.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/data/repositories/clue_repository.dart';
import 'package:scoutquest/data/repositories/quest_repository.dart';
import 'package:scoutquest/utils/alert.dart';

class CluesScreen extends StatefulWidget {
  final Quest quest;
  const CluesScreen({super.key, required this.quest});

  @override
  CluesScreenState createState() => CluesScreenState();
}

class CluesScreenState extends State<CluesScreen> {
  List<ClueCategory> categories = [];
  List<Clue> uncategorizedClues = [];
  List<Clue> clues = [];
  Clue? selectedClue;
  late ClueRepository clueRepository;
  late QuestRepository questRepository;
  bool isBottomSheetOpen = false;

  @override
  void initState() {
    super.initState();
    clueRepository = ClueRepository(widget.quest);
    questRepository = QuestRepository();
    loadClueInfo();
  }

  Future<void> loadClueInfo() async {
    final questStatus =
        await questRepository.getUserQuestStatus(widget.quest.id);
    if (questStatus == QuestStatus.completed) {
      Navigator.of(context)
          .pushNamed(questCompleteRoute, arguments: widget.quest);
      return;
    }

    if (questStatus == QuestStatus.unlocked) {
      await questRepository.updateUserQuestStatus(
          widget.quest.id, QuestStatus.inProgress);
    }

    clues = await clueRepository.getUserQuestClues();
    final List<Clue> noCategory = [];
    final List<ClueCategory> loadedCategories = [];

    for (final clue in clues) {
      if (clue.category == null || clue.category?.trim().isEmpty == true) {
        noCategory.add(clue);
        continue;
      }

      final category = loadedCategories
          .firstWhere((cat) => cat.name == clue.category, orElse: () {
        final newCategory = ClueCategory(name: clue.category ?? '', clues: []);
        loadedCategories.add(newCategory);
        return newCategory;
      });
      category.clues.add(clue);
    }

    // Sort clues in each category by status priority
    for (final category in loadedCategories) {
      category.clues.sort(
          (a, b) => _getStatusPriority(a).compareTo(_getStatusPriority(b)));
    }

    // Sort uncategorized clues by status priority
    noCategory
        .sort((a, b) => _getStatusPriority(a).compareTo(_getStatusPriority(b)));

    setState(() {
      categories = loadedCategories;
      uncategorizedClues = noCategory;
    });
  }

  // Helper method to determine status priority for sorting
  int _getStatusPriority(Clue clue) {
    // Assuming you have these properties on your Clue model
    // You may need to adjust these conditions based on your actual Clue model properties

    if (clue.status == ClueStatus.inProgress) {
      return 0; // InProgress - highest priority
    }
    if (clue.status == ClueStatus.unlocked) {
      return 1; // Unlocked - second priority
    }
    if (clue.status == ClueStatus.locked) {
      return 2; // Locked - third priority
    }
    if (clue.status == ClueStatus.completed) {
      return 3; // Completed - lowest priority
    }

    return 4; // Default case
  }

  void selectClue(Clue clue) {
    if (!clue.isFound) {
      return;
    }

    Navigator.of(context).pushNamed(
      clueDetailRoute,
      arguments: {
        'clue': clue,
        'quest': widget.quest,
      },
    );
  }

  void addClue() {
    setState(() => isBottomSheetOpen = true);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return QRScanner(
          title: 'Add Clue',
          description: 'Scan the QR Code',
          onQRCodeScanned: processQRCodeClue,
        );
      },
    ).then((_) => {setState(() => isBottomSheetOpen = false)});
  }

  void processQRCodeClue(String? value) {
    if (value == null) {
      return;
    }

    if (isBottomSheetOpen) {
      Navigator.of(context).pop();
    }

    if (!value.contains("/clues/")) {
      Alert.toastBottom('Invalid QR Code.');
      return;
    }

    // TODO make sure it's the right quests
    // sample scan value = "http://scoutquest.co/quests/quest_element_2023/clues/FireClue1-4CX6TZPA.html"
    RegExp regExp = RegExp(r'\/([A-Za-z0-9-]+)\.html');
    Match? match = regExp.firstMatch(value);

    if (match != null) {
      String clueCode = match.group(1)!;
      clueRepository.verifyClue(clueCode).then((isValid) {
        if (isValid) {
          markClueFound(clueCode);
        } else {
          Alert.toastBottom('Invalid QR Code. 2');
        }
      });
    } else {
      Alert.toastBottom('Invalid QR Code. 1');
    }
  }

  Future<void> markClueFound(String code) async {
    final clue = clues.firstWhere((clue) => clue.code == code);

    clueRepository.updateClueProgress(clue.id, 1);

    await loadClueInfo();
    final category = categories.firstWhere((cat) => cat.name == clue.category);
    expandCategory(category);

    final updatedClue = clues.firstWhere((clue) => clue.code == code);
    Navigator.of(context).pushNamed(
      clueDetailRoute,
      arguments: {
        'clue': updatedClue,
        'quest': widget.quest,
      },
    );
  }

  void goBack() {
    Navigator.of(context).pushNamed(cluesRoute, arguments: widget.quest);
  }

  void collapseCategory(ClueCategory category) {
    setState(() {
      category.isExpanded = false;
    });
  }

  void expandCategory(ClueCategory category) {
    setState(() {
      category.isExpanded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarManager(
        appBar: AppBar(),
        hasBackButton: true,
        backButtonOnPressed: () => {
          Navigator.of(context).pushReplacementNamed(questsRoute),
        },
        quest: widget.quest,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => loadClueInfo(),
              child: ListView(
                children: [
                  if (uncategorizedClues.isNotEmpty) ...[
                    ...uncategorizedClues.map((clue) => ClueRow(
                          clue: clue,
                          onTap: () => selectClue(clue),
                        )),
                    const Divider(),
                  ],
                  ...categories.map((category) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => category.isExpanded
                              ? collapseCategory(category)
                              : expandCategory(category),
                          child: CategoryHeader(
                            category: category,
                            isExpanded: category.isExpanded,
                          ),
                        ),
                        if (category.isExpanded)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: category.clues.length,
                            itemBuilder: (ctx, index) {
                              final clue = category.clues[index];
                              return ClueRow(
                                clue: clue,
                                onTap: () => selectClue(clue),
                              );
                            },
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     // Handle the action when the button is pressed
      //     // You can add your code to open a bottom sheet or any other action here
      //     addClue();
      //   },
      //   label: const Text(
      //     "Add Clue",
      //     style: TextStyle(
      //       fontWeight: FontWeight.w900,
      //       fontSize: 18.0,
      //     ),
      //   ), // Change the button label // Add an optional icon
      // ),
    );
  }
}
