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
import 'package:scoutquest/utils/logger.dart';

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
  late Quest currentQuest;

  // Prevent processing the same scan multiple times
  bool _isProcessingQRCode = false;

  @override
  void initState() {
    super.initState();
    clueRepository = ClueRepository(widget.quest);
    questRepository = QuestRepository();
    currentQuest = widget.quest;
    loadClueInfo();
  }

  Future<void> loadClueInfo() async {
    final questStatus =
        await questRepository.getUserQuestStatus(widget.quest.id);

    if (questStatus == QuestStatus.completed) {
      if (!mounted) return;
      Navigator.of(context)
          .pushNamed(questCompleteRoute, arguments: widget.quest);
      return;
    }

    if (questStatus == QuestStatus.unlocked) {
      await questRepository.updateUserQuestStatus(
          widget.quest.id, QuestStatus.inProgress);
    }

    currentQuest = await questRepository.refreshQuest(widget.quest);

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

    if (!mounted) return;
    setState(() {
      categories = loadedCategories;
      uncategorizedClues = noCategory;
      currentQuest = currentQuest;
    });
  }

  // Helper method to determine status priority for sorting
  int _getStatusPriority(Clue clue) {
    // Assuming you have these properties on your Clue model
    // You may need to adjust these conditions based on your actual Clue model properties
    if (clue.status == ClueStatus.inProgress ||
        (clue.status != ClueStatus.locked && clue.infoOnly)) {
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
    if (!mounted) return;
    Navigator.of(context).pushNamed(
      clueDetailRoute,
      arguments: {
        'clue': clue,
        'quest': currentQuest, // Changed from widget.quest
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
    ).then((_) {
      if (!mounted) return;
      setState(() => isBottomSheetOpen = false);
    });
  }

  Future<void> processQRCodeClue(String? value) async {
    if (value == null) return;

    // Debounce / guard: ignore if already handling a scan
    if (_isProcessingQRCode) return;
    _isProcessingQRCode = true;

    try {
      if (isBottomSheetOpen && mounted) {
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
        final isValid = await clueRepository.verifyClue(clueCode);
        if (isValid) {
          await markClueFound(clueCode);
        } else {
          Alert.toastBottom('Invalid QR Code. 2');
        }
      } else {
        Alert.toastBottom('Invalid QR Code. 1');
      }
    } finally {
      _isProcessingQRCode = false;
    }
  }

  Future<void> markClueFound(String code) async {
    final clue = clues.firstWhere((clue) => clue.code == code);

    await clueRepository.updateClueProgress(clue.id, 1);

    await loadClueInfo();
    Logger.log('Clue found: $code, loaded clue info');
    final updatedClue = clues.firstWhere((clue) => clue.code == code);
    selectClue(updatedClue);
  }

  void goBack() {
    Navigator.of(context).pushNamed(cluesRoute,
        arguments: currentQuest); // Changed from widget.quest
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
        quest: currentQuest, // Changed from widget.quest to currentQuest
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
      floatingActionButton: currentQuest.canAddClues
          ? FloatingActionButton.extended(
              onPressed: addClue,
              label: const Text(
                "Add Clue",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18.0,
                ),
              ),
            )
          : null,
    );
  }
}
