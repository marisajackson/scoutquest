import 'package:flutter/material.dart';

class AppBarManager extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  const AppBarManager({
    super.key,
    this.actions = const [],
    this.hasBackButton = false,
    this.backButtonOnPressed = null,
    required this.appBar,
  });

  final List<Widget>? actions;
  final bool hasBackButton;
  final VoidCallback? backButtonOnPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // removes shadow
      elevation: 0, // Removes shadow
      leading:
          hasBackButton ? BackButton(onPressed: backButtonOnPressed) : null,
      title: Image.asset("assets/brand/logos/logo-white.png", height: 60),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height + 10);
}
