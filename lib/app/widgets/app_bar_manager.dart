import 'package:flutter/material.dart';

class AppBarManager extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  const AppBarManager({
    Key? key,
    this.actions = const [],
    this.hasBackButton = false,
    required this.appBar,
  }) : super(key: key);

  final List<Widget>? actions;
  final bool hasBackButton;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // removes shadow
      elevation: 0, // Removes shadow
      leading: hasBackButton ? const BackButton() : null,
      title: Image.asset("assets/brand/logos/logo-white.png", height: 60),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height + 10);
}
