import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scoutquest/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpNote extends StatelessWidget {
  const HelpNote({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context)
            .style
            .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
        children: [
          const TextSpan(text: 'Check out the '),
          TextSpan(
            text: 'ScoutQuest Guide',
            style: const TextStyle(
              color: ScoutQuestColors.primaryAction,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse('https://scoutquest.co/help'));
              },
          ),
          const TextSpan(
              text:
                  ' for everything you need to know about setting up and completing your quest.'),
          const TextSpan(text: '\n\n'),
          const TextSpan(text: 'If you need more help, contact us at '),
          TextSpan(
            text: 'help@scoutquest.co',
            style: const TextStyle(
              color: ScoutQuestColors.primaryAction,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse('mailto:help@scoutquest.co'));
              },
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
