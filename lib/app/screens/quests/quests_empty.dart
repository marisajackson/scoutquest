import 'package:flutter/material.dart';

class QuestsEmpty extends StatelessWidget {
  const QuestsEmpty({
    super.key,
    required this.onAddQuest,
  });

  final VoidCallback? onAddQuest;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              size: 100.0, // Increased size
              color: Colors.grey,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Welcome to the Scout Quest Companion App!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'This app is designed to organize your digital clues as you navigate through your Scout Quest adventure.',
              style: TextStyle(
                fontSize: 20.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22.0),
            const Text(
              'Getting Started Is Simple:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0), // Adjusted spacing
            // const ListTile(
            //   leading: Icon(Icons.note_add, size: 30.0), // Increased icon size
            //   title: Text(
            //     'Register for an Adventure',
            //     style: TextStyle(fontSize: 18.0),
            //   ),
            //   subtitle: Text(
            //     'Secure your spot in a quest by signing up at http://scoutquest.co.',
            //     style: TextStyle(fontSize: 16.0),
            //   ),
            // ),
            const ListTile(
              leading: Icon(Icons.qr_code_scanner,
                  size: 30.0), // Increased icon size
              title: Text(
                'Scan Your Quest QR Code',
                style: TextStyle(fontSize: 18.0),
              ),
              subtitle: Text(
                "Use the 'Add Quest' button here to scan the QR code to start your quest.",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            const ListTile(
              leading:
                  Icon(Icons.track_changes, size: 30.0), // Increased icon size
              title: Text(
                'Follow the Clues',
                style: TextStyle(fontSize: 18.0),
              ),
              subtitle: Text(
                'The app will keep track of your digital clues and progress as you uncover the mysteries of your quest.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(height: 24.0),
            FloatingActionButton.extended(
              onPressed: onAddQuest,
              label: const Text(
                'Add Quest',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            const SizedBox(height: 24.0)
          ],
        ),
      ),
    ));
  }
}
