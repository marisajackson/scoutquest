import 'package:flutter/material.dart';
import 'package:scoutquest/utils/logger.dart';

class QuestsEmpty extends StatelessWidget {
  const QuestsEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_circle,
            size: 100.0,
            color: Colors.grey,
          ),
          const Text(
            'No quests available',
            style: TextStyle(fontSize: 18.0, color: Colors.grey),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              Logger.log('Join a Quest button pressed');
            },
            child: const Text('Join a Quest'),
          ),
        ],
      ),
    );
  }
}
