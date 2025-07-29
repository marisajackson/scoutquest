import 'package:flutter/material.dart';
import 'package:scoutquest/app.routes.dart';
import 'package:scoutquest/utils/constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Delay navigation to the quests route by one second
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed(questsRoute);
    });

    return Scaffold(
      body: Container(
        color: ScoutQuestColors.primaryAction,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Your app logo or image goes here
              Image.asset(
                'assets/brand/logos/logo-white.png',
                width: 250,
                // adjust width and height as needed
              ),
            ],
          ),
        ),
      ),
    );
  }
}
