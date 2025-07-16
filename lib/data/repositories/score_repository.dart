import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitScore({
    required String questId,
    required String teamName,
    required String email,
    required Duration duration,
  }) async {
    try {
      await _firestore.collection('scores').add({
        'questId': questId,
        'teamName': teamName,
        'email': email,
        'duration': duration.inSeconds,
        'submittedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to submit score: $e');
    }
  }
}
