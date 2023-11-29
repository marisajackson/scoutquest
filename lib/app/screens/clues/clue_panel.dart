import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:scoutquest/app/models/clue.dart';
import 'package:scoutquest/app/widgets/audio_player.dart';
import 'package:scoutquest/utils/logger.dart';

class CluePanel extends StatelessWidget {
  const CluePanel({
    Key? key,
    required this.selectedClue,
    required this.onTap,
  }) : super(key: key);

  final Clue selectedClue;
  final VoidCallback onTap;

  void submitSecretCode() {
    Logger.log('Secret code submitted: ${selectedClue.secretCode}');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            selectedClue.label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
          ),
          Html(
            data:
                "<div style='text-align: center; font-size: 18px; font-weight: bold;'>${selectedClue.displayText}</div>",
          ),
          const SizedBox(height: 16.0),
          if (selectedClue.hasSecret) // Check if secret code exists
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Enter Secret Code',
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.0), // Define border style
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                  ),
                  onPressed: () =>
                      submitSecretCode(), // Pass the secret code to the callback
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          if (selectedClue.image != null)
            Image.asset(
              selectedClue.displayImage!,
              height: 200.0,
              fit: BoxFit.cover,
            ),
          if (selectedClue.audio != null)
            AudioControlWidget(audioAsset: selectedClue.audio!),
          const SizedBox(height: 40.0),
        ],
      ),
    );
  }
}
