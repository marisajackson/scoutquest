import 'package:flutter/material.dart';

class AppBarManager extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  const AppBarManager({
    super.key,
    this.actions = const [],
    this.hasBackButton = false,
    this.questName,
    this.backButtonOnPressed,
    this.timer,
    required this.appBar,
  });

  final List<Widget>? actions;
  final bool hasBackButton;
  final String? questName;
  final VoidCallback? backButtonOnPressed;
  final String? timer;

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
      bottom: questName != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        questName!,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (timer != null) ...[
                      const SizedBox(width: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timer!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFeatures: [
                                FontFeature.tabularFigures()
                              ], // Monospace numbers
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(0), child: Container()),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      appBar.preferredSize.height + (questName != null ? 50 : 0));
}
