import 'package:flutter/material.dart';
import 'package:scoutquest/data/models/clue.dart';
import 'package:scoutquest/app/widgets/circle_progress_bar.dart';
import 'package:scoutquest/app/screens/clues/clue_panel.dart';
import 'package:scoutquest/app/screens/clues/clue_row.dart';
import 'package:scoutquest/data/models/quest.dart';
import 'package:scoutquest/data/repositories/clue_repository.dart';
// import 'package:scoutquest/utils/logger.dart';

class CluesScreen extends StatefulWidget {
  final Quest quest;
  const CluesScreen({Key? key, required this.quest}) : super(key: key);

  @override
  CluesScreenState createState() => CluesScreenState();
}

class CluesScreenState extends State<CluesScreen> {
  List<Category> categories = [];
  Clue? selectedClue;
  late ClueRepository clueRepository;

  @override
  void initState() {
    super.initState();
    clueRepository = ClueRepository(widget.quest);
    loadClueInfo();
  }

  Future<void> loadClueInfo() async {
    final clues = await clueRepository.getUserQuestClues();
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

  void selectClue(Clue? clue) {
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
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height, // Set a fixed height
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
          ),
        ],
      ),
    );
  }
}

class Category {
  final String name;
  bool isExpanded;
  final List<Clue> clues;

  Category(
      {required this.name, this.isExpanded = false, this.clues = const []});
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26.0),
      height: 90.0,
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
          const CircleProgressBar(
            count: 2,
            total: 10,
            progressColor: Colors.green,
            backgroundColor: Colors.grey,
            textStyle: TextStyle(
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
                    fontWeight: FontWeight.bold,
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
