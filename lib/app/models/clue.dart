class Clue {
  final String id;
  final String code;
  final String label;
  final String type;
  final String? category;
  final List<ClueStep> steps;
  int progressStep;
  ClueStatus status = ClueStatus.locked;

  bool get isFound => progressStep > 0;
  bool get isUnlocked => progressStep > 0;

  ClueStep get currentStep {
    return steps[progressStep];
  }

  String get getShortText {
    return currentStep.shortText ?? '';
  }

  double get getProgress {
    return progressStep / steps.length;
  }

  Clue({
    required this.id,
    required this.code,
    required this.label,
    required this.type,
    required this.steps,
    required this.category,
    this.progressStep = 0,
  });

  factory Clue.fromJson(Map<String, dynamic> json) {
    return Clue(
      id: json['id'] as String,
      code: json['code'] as String,
      label: json['label'] as String,
      type: json['type'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((s) => ClueStep.fromJson(s as Map<String, dynamic>))
          .toList(),
      category: json['category'] as String?,
      progressStep: json['progressStep'] as int? ?? 0,
    );
  }
}

class ClueStep {
  final int step;
  final String type;
  final String text;

  // Optional fields used by various step types
  final List<String>? correctOrder;
  final String? secretCode;
  final String? shortText;
  final String? audio;
  final String? image;

  ClueStep({
    required this.step,
    required this.type,
    required this.text,
    this.correctOrder,
    this.secretCode,
    this.shortText,
    this.audio,
    this.image,
  });

  factory ClueStep.fromJson(Map<String, dynamic> json) {
    return ClueStep(
      step: json['step'] as int,
      type: json['type'] as String,
      text: json['text'] as String,
      correctOrder: json['correctOrder'] != null
          ? List<String>.from(json['correctOrder'] as List<dynamic>)
          : null,
      secretCode: json['secretCode'] as String?,
      shortText: json['shortText'] as String?,
      audio: json['audio'] as String?,
      image: json['image'] as String?,
    );
  }
}

enum ClueStatus {
  locked,
  found,
  unlocked,
}
