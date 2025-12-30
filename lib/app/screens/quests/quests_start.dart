import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/app.routes.dart';
import 'package:scoutquest/app/widgets/app_bar_manager.dart';

class QuestsStart extends StatefulWidget {
  final Quest quest;
  const QuestsStart({super.key, required this.quest});

  @override
  State<QuestsStart> createState() => _QuestsStartState();
}

class _QuestsStartState extends State<QuestsStart> {
  bool _liability = false;
  bool _publicParkAcknowledged = false;
  bool _ageConfirmed = false;
  final TapGestureRecognizer _termsRecognizer = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _termsRecognizer.onTap = _openTerms;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    super.dispose();
  }

  void _startQuest(BuildContext context) {
    if (!_liability) return;
    if (!_publicParkAcknowledged) return;
    if (!_ageConfirmed) return;
    Navigator.of(context).pushNamed(cluesRoute, arguments: widget.quest);
  }

  Future<void> _openTerms() async {
    // Replace this URL with your actual terms/waiver URL or route.
    final Uri url = Uri.parse('https://example.com/scout-quest-terms');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarManager(
        appBar: AppBar(),
        hasBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Html(
              data:
                  "<div style='text-align: center; font-size: 20px; font-weight: bold;'>${widget.quest.welcomeHtml}</div>",
            ),
            CheckboxListTile(
              value: _liability,
              onChanged: (v) => setState(() => _liability = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.blue,
              visualDensity:
                  const VisualDensity(horizontal: -3.0, vertical: -1.0),
              title: RichText(
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 12),
                  children: [
                    const TextSpan(text: 'I have read and agree to the '),
                    TextSpan(
                      text:
                          'Scout Quest Terms of Participation and Liability Waiver',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: _termsRecognizer,
                    ),
                    const TextSpan(
                        text:
                            ' on behalf of myself and all members of my group.'),
                  ],
                ),
              ),
            ),
            CheckboxListTile(
              value: _publicParkAcknowledged,
              onChanged: (v) =>
                  setState(() => _publicParkAcknowledged = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              // blue when checked
              activeColor: Colors.blue,
              visualDensity:
                  const VisualDensity(horizontal: -3.0, vertical: -1.0),
              title: Text(
                'I understand that this activity takes place in a public park and I agree, on behalf of myself and all members of my group, to follow all posted park rules, respect public property, and behave lawfully.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 14),
              ),
            ),
            CheckboxListTile(
              value: _ageConfirmed,
              onChanged: (v) => setState(() => _ageConfirmed = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.blue,
              visualDensity:
                  const VisualDensity(horizontal: -3.0, vertical: -1.0),
              title: Text(
                'I confirm, on behalf of myself and all members of my group, that all participants are at least 18 years of age, or are participating under the supervision of a parent or legal guardian.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
            FloatingActionButton.extended(
              onPressed: _liability ? () => _startQuest(context) : null,
              label: const Text(
                'Start Quest',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
