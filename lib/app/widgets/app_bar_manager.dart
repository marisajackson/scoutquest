import 'package:flutter/material.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/app/widgets/quest_header.dart';

class AppBarManager extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  const AppBarManager({
    super.key,
    this.actions = const [],
    this.hasBackButton = false,
    this.quest,
    this.backButtonOnPressed,
    this.onTimerTapped,
    required this.appBar,
  });

  final List<Widget>? actions;
  final bool hasBackButton;
  final Quest? quest;
  final VoidCallback? backButtonOnPressed;
  final VoidCallback? onTimerTapped;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      leading:
          hasBackButton ? BackButton(onPressed: backButtonOnPressed) : null,
      title: SizedBox(
        height: 60,
        child: Image.asset(
          "assets/brand/logos/logo-white.png",
          fit: BoxFit.contain,
        ),
      ),
      centerTitle: true,
      actions: [
        ...?actions,
      ],
      bottom: quest != null
          ? QuestHeader(
              quest: quest!,
              onTimerTapped: onTimerTapped,
            )
          : null,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(appBar.preferredSize.height + (quest != null ? 50 : 0));
}
