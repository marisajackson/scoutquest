import 'package:flutter/material.dart';
import 'package:scoutquest/app/models/category.dart';
import 'package:scoutquest/app/widgets/qr_scanner.dart';
import 'package:scoutquest/app/models/clue.dart';
import 'package:scoutquest/app/widgets/circle_progress_bar.dart';
import 'package:scoutquest/app/screens/clues/clue_panel.dart';
import 'package:scoutquest/app/screens/clues/clue_row.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/data/repositories/clue_repository.dart';
import 'package:scoutquest/utils/logger.dart';

class CluesScreen extends StatefulWidget {
  final Quest quest;
  const CluesScreen({Key? key, required this.quest}) : super(key: key);

  @override
  CluesScreenState createState() => CluesScreenState();
}

class CluesScreenState extends State<CluesScreen> {
  List<Category> categories = [];
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
    final List<Category> loadedCategories = [];

    for (final clue in clues) {
      final category = loadedCategories
          .firstWhere((cat) => cat.name == clue.category, orElse: () {
        final newCategory = Category(name: clue.category, clues: []);
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
    if (clue.isUnlocked == false) {
      return;
    }

    setState(() {
      selectedClue = clue;
    });

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return CluePanel(
            selectedClue: selectedClue,
            onTap: () {
              Navigator.of(context).pop(); // Close the BottomSheet
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
    // sample scan value = "http://scoutquest.co/quest_element_2023/FireClue1-4CX6TZPA.html"
    RegExp regExp = RegExp(r'\/([A-Za-z0-9-]+)\.html');
    Match? match = regExp.firstMatch(value);

    if (match != null) {
      String clueCode = match.group(1)!;
      Logger.log(clueCode); // 'FireClue1-4CX6TZPA'
      unlockClue(clueCode);
    } else {
      Logger.log('No match found.');
    }
  }

  Future<void> unlockClue(String code) async {
    final clue = clues.firstWhere((clue) => clue.code == code);
    clueRepository.unlockClue(clue.id);
    await loadClueInfo();
    final category = categories.firstWhere((cat) => cat.name == clue.category);
    expandCategory(category);
    goBack();
    selectClue(clues.firstWhere((clue) => clue.code == code));
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  void collapseCategory(Category category) {
    setState(() {
      category.isExpanded = false;
    });
  }

  void expandCategory(Category category) {
    setState(() {
      category.isExpanded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scout Quest"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // Customize icon color
            onPressed: () {
              addClue();
            },
          ),
        ],
      ),
      body: Container(
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
                  child: _CategoryHeader(
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
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final Category category;
  final bool isExpanded;

  const _CategoryHeader({
    Key? key,
    required this.category,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26.0),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleProgressBar(
            count: category.clues.where((clue) => clue.isUnlocked).length,
            total: category.clues.length,
            backgroundColor: Colors.grey,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 30.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
