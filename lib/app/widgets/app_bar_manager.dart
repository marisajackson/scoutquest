import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
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
        if (quest?.tipsHtml != null) ...[
          IconButton(
            icon: const Icon(Icons.help_outline, size: 32),
            onPressed: () => _showTipsBottomSheet(context),
          ),
        ],
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

  void _showTipsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Html(
                    data: quest?.tipsHtml ?? '',
                    style: {
                      "body": Style(
                        fontSize: FontSize(18),
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                      "li": Style(
                        fontSize: FontSize(18),
                        margin: Margins.only(bottom: 5),
                        textAlign: TextAlign.left,
                      ),
                      "ul": Style(
                        margin: Margins.zero,
                      ),
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(appBar.preferredSize.height + (quest != null ? 50 : 0));
}
