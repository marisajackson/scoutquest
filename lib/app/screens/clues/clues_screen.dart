import 'package:flutter/material.dart';
import 'package:scoutquest/app.routes.dart';
import 'package:scoutquest/app/models/clue_category.dart';
import 'package:scoutquest/app/screens/clues/category_header.dart';
import 'package:scoutquest/app/widgets/app_bar_manager.dart';
import 'package:scoutquest/app/widgets/qr_scanner.dart';
import 'package:scoutquest/app/models/clue.dart';
import 'package:scoutquest/app/screens/clues/clue_panel.dart';
import 'package:scoutquest/app/screens/clues/clue_row.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/data/repositories/clue_repository.dart';
import 'package:scoutquest/utils/alert.dart';
import 'package:scoutquest/utils/constants.dart';

class CluesScreen extends StatefulWidget {
  final Quest quest;
  const CluesScreen({Key? key, required this.quest}) : super(key: key);

  @override
  CluesScreenState createState() => CluesScreenState();
}

class CluesScreenState extends State<CluesScreen> {
  List<ClueCategory> categories = [];
  List<Clue> clues = [];
  Clue? selectedClue;
  late ClueRepository clueRepository;

  @override
  void initState() {
    super.initState();
    clueRepository = ClueRepository(widget.quest);
    loadClueInfo();
  }

  Future<void> loadClueInfo() async {
    clues = await clueRepository.getUserQuestClues();
    final List<ClueCategory> loadedCategories = [];

    for (final clue in clues) {
      final category = loadedCategories
          .firstWhere((cat) => cat.name == clue.category, orElse: () {
        final newCategory = ClueCategory(name: clue.category, clues: []);
        loadedCategories.add(newCategory);
        return newCategory;
      });
      category.clues.add(clue);
    }

    setState(() {
      categories = loadedCategories;
    });
  }

  void selectClue(Clue clue) {
    if (!clue.isFound) {
      return;
    }

    setState(() {
      selectedClue = clue;
    });

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return CluePanel(
            clueRepository: clueRepository,
            selectedClue: clue,
            onTap: () {
              Navigator.of(context).pop(); // Close the BottomSheet
              loadClueInfo();
            },
          );
        });
  }

  void addClue() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return QRScanner(
          title: 'Add Clue',
          description: 'Scan the QR Code',
          onQRCodeScanned: processQRCodeClue,
        );
      },
    );
  }

  void processQRCodeClue(String? value) {
    if (value == null) {
      return;
    }

    if (!value.contains("/clues/")) {
      Alert.toastBottom('Invalid QR Code.');
      return;
    }

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

    if (clue.hasSecret) {
      clueRepository.updateClueStatus(clue.id, ClueStatus.found);
    } else {
      clueRepository.updateClueStatus(clue.id, ClueStatus.unlocked);
    }

    await loadClueInfo();
    final category = categories.firstWhere((cat) => cat.name == clue.category);
    expandCategory(category);
    selectClue(clues.firstWhere((clue) => clue.code == code));
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
      ),
      body: Column(
        children: [
          // Content below the AppBar
          Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            alignment: Alignment.center,
            color: ScoutQuestColors.primaryAction,
            child: Text(
              widget.quest.name,
              style: const TextStyle(
                fontSize: 24.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => loadClueInfo(),
              child: ListView(
                children: categories.map((category) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (category.isExpanded) {
                            collapseCategory(category);
                          } else {
                            expandCategory(category);
                          }
                        },
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
                          itemBuilder: (context, index) {
                            final clue = category.clues[index];
                            return ClueRow(
                              clue: clue,
                              onTap: () => selectClue(clue),
                            );
                          },
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handle the action when the button is pressed
          // You can add your code to open a bottom sheet or any other action here
          addClue();
        },
        label: const Text(
          "Add Clue",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18.0,
          ),
        ), // Change the button label // Add an optional icon
      ),
    );
  }
}
