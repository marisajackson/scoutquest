import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scoutquest/app/models/score.dart';

class ScoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Presubmit score data without team name and email
  Future<String> presubmitScore({
    required String questId,
    required Duration duration,
    Map<String, dynamic>? questData,
  }) async {
    try {
      final submissionData = {
        'questId': questId,
        'duration': duration.inSeconds,
        'submittedAt': DateTime.now().toIso8601String(),
        'isPresubmitted': true,
        'teamSubmitted': false,
      };

      // Add quest data if provided
      if (questData != null) {
        submissionData['questData'] = questData;
      }

      final docRef = await _firestore.collection('scores').add(submissionData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to presubmit score: $e');
    }
  }

  // Update presubmitted score with team information
  Future<void> updatePresubmittedScore({
    required String documentId,
    required String teamName,
    required String email,
  }) async {
    try {
      await _firestore.collection('scores').doc(documentId).update({
        'teamName': teamName,
        'email': email,
        'teamSubmitted': true,
        'teamSubmittedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update presubmitted score: $e');
    }
  }

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
        'teamSubmitted': true,
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
          .where('teamSubmitted', isEqualTo: true)
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
