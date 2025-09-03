import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoutquest/app/models/score.dart';

class ScoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitScore({
    required String questId,
    required String teamName,
    required String email,
    required Duration duration,
    Map<String, dynamic>? questData,
  }) async {
    try {
      final submissionData = {
        'questId': questId,
        'teamName': teamName,
        'email': email,
        'duration': duration.inSeconds,
        'submittedAt': DateTime.now().toIso8601String(),
      };

      // Add quest data if provided
      if (questData != null) {
        submissionData['questData'] = questData;
      }

      await _firestore.collection('scores').add(submissionData);
    } catch (e) {
      throw Exception('Failed to submit score: $e');
    }
  }

  Future<List<Score>> fetchScores(String questId) async {
    try {
      final snapshot = await _firestore
          .collection('scores')
          .where('questId', isEqualTo: questId)
          .orderBy('duration')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Score(
          teamName: data['teamName'],
          duration: Duration(seconds: data['duration']),
          completedAt: DateTime.parse(data['submittedAt']),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch scores: $e');
    }
  }
}
