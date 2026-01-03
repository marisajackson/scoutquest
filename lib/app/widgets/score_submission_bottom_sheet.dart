import 'package:flutter/material.dart';
import 'package:scoutquest/app.routes.dart';
import 'package:scoutquest/app/models/quest.dart';
import 'package:scoutquest/data/repositories/quest_repository.dart';
import 'package:scoutquest/data/repositories/score_repository.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scoutquest/utils/constants.dart';
import 'package:scoutquest/app/widgets/text_input.dart';

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
  final _questRepo = QuestRepository();
  bool _acceptsMarketing = false;

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
      // Check if there's a presubmitted score to update
      final presubmittedDocId =
          await _questRepo.getPresubmittedScoreDocId(widget.quest.id);

      if (presubmittedDocId != null) {
        // Update the presubmitted score with team information
        await _scoreRepository.updatePresubmittedScore(
          documentId: presubmittedDocId,
          teamName: _teamNameController.text.trim(),
          email: _emailController.text.trim().toLowerCase(),
          acceptsMarketing: _acceptsMarketing,
        );
      } else {
        // Fallback to creating a new score entry
        final questData =
            await _questRepo.getQuestSubmissionData(widget.quest.id);

        await _scoreRepository.submitScore(
          questId: widget.quest.id,
          teamName: _teamNameController.text.trim(),
          email: _emailController.text.trim().toLowerCase(),
          acceptsMarketing: _acceptsMarketing,
          duration: widget.duration,
          questData: questData,
        );
      }

      if (mounted) {
        // update quest status to submitted
        await _questRepo.updateUserQuestStatus(
          widget.quest.id,
          QuestStatus.submitted,
        );
        Navigator.of(context)
            .pushNamed(questScoreboardRoute, arguments: widget.quest);

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
        left: 26.0, // Match the padding from quest list items
        right: 26.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(10.0), // Match quest list border radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
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
              style: const TextStyle(
                fontWeight: FontWeight.w900, // Match quest name font weight
                fontSize: 24.0, // Match quest header font size
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.quest.name,
              style: const TextStyle(
                fontSize: 20.0,
                color: Colors.black54, // Lighter color for quest name
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextInput(
                controller: _teamNameController,
                labelText: 'Team Name',
                hintText: 'Enter your team name',
                validator: _validateTeamName,
                enabled: !_isSubmitting,
                prefixIcon: Icon(Icons.group,
                    size: 30.0, color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            TextInput(
              controller: _emailController,
              labelText: 'Email Address',
              hintText: 'Enter your email address',
              validator: _validateEmail,
              enabled: !_isSubmitting,
              prefixIcon: Icon(Icons.email,
                  size: 30.0, color: Theme.of(context).colorScheme.primary),
            ),
            CheckboxListTile(
              value: _acceptsMarketing,
              onChanged: (v) => setState(() => _acceptsMarketing = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              // blue when checked
              activeColor: Colors.blue,
              visualDensity:
                  const VisualDensity(horizontal: -3.0, vertical: -1.0),
              title: Text(
                'Email me about future Scout Quest events and updates.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            FloatingActionButton.extended(
              onPressed: _isSubmitting ? null : _submitScore,
              backgroundColor: _isSubmitting
                  ? Colors.grey
                  : ScoutQuestColors.secondaryAction,
              label: _isSubmitting
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
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed:
                  _isSubmitting ? null : () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
