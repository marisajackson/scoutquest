import 'package:flutter/material.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/data/repositories/score_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ScoreSubmissionBottomSheet extends StatefulWidget {
  final Quest quest;
  final Duration duration;

  const ScoreSubmissionBottomSheet({
    super.key,
    required this.quest,
    required this.duration,
  });

  @override
  State<ScoreSubmissionBottomSheet> createState() =>
      _ScoreSubmissionBottomSheetState();
}

class _ScoreSubmissionBottomSheetState
    extends State<ScoreSubmissionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _scoreRepository = ScoreRepository();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _teamNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateTeamName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Team name is required';
    }
    if (value.length < 2) {
      return 'Team name must be at least 2 characters';
    }
    return null;
  }

  Future<void> _submitScore() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _scoreRepository.submitScore(
        questId: widget.quest.id,
        teamName: _teamNameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        duration: widget.duration,
      );

      if (mounted) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
          msg: 'Score submitted successfully!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Failed to submit score. Please try again.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Submit Your Score',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Quest: ${widget.quest.name}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _teamNameController,
              decoration: const InputDecoration(
                labelText: 'Team Name',
                hintText: 'Enter your team name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
              ),
              validator: _validateTeamName,
              textCapitalization: TextCapitalization.words,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitScore,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit Score',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed:
                  _isSubmitting ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
