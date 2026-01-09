import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scoutquest/app.routes.dart';
import 'package:scoutquest/utils/constants.dart';
import 'package:scoutquest/deep_links.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 3), () {
      // If we got disposed (e.g., deep link already navigated), do nothing.
      if (!mounted) return;

      // If deep links already routed somewhere, don't override it.
      if (deepLinkNavigated) return;

      Navigator.of(context).pushReplacementNamed(questsRoute);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: ScoutQuestColors.primaryAction,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/brand/logos/logo-white.png',
                width: 250,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
