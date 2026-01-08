class Clue {
  final String id;
  final String code;
  final String label;
  final String type;
  final String? category;
  final String? icon;
  final String? iconImage;
  final List<ClueStep> steps;
  final bool infoOnly;
  int progressStep;
  // ClueStatus status = ClueStatus.locked;

  bool get isFound => progressStep > 0;
  bool get isUnlocked => progressStep > 0;

  ClueStep get currentStep {
    return steps.firstWhere(
      (s) => s.step == progressStep,
      orElse: () => steps.first,
    );
  }

  ClueStatus get status {
    if (progressStep >= steps.length) {
      return ClueStatus.completed;
    } else if (progressStep > 1) {
      return ClueStatus.inProgress;
    } else if (progressStep > 0) {
      return ClueStatus.unlocked;
    } else {
      return ClueStatus.locked;
    }
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
    this.icon,
    this.iconImage,
    this.progressStep = 0,
    this.infoOnly = false,
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
      icon: json['icon'] as String?,
      iconImage: json['iconImage'] as String?,
      progressStep: json['progressStep'] as int? ?? 0,
      infoOnly: json['infoOnly'] as bool? ?? false,
    );
  }
}

class ClueStep {
  final int step;
  final String? type;
  final String text;

  // Optional fields used by various step types
  final List<String>? correctOrder;
  final String? secretCode;
  final String? shortText;
  final String? audio;
  final String? image;
  final List<Hint>? hints;

  ClueStep({
    required this.step,
    this.type,
    required this.text,
    this.correctOrder,
    this.secretCode,
    this.shortText,
    this.audio,
    this.image,
    this.hints,
  });

  factory ClueStep.fromJson(Map<String, dynamic> json) {
    return ClueStep(
      step: json['step'] as int,
      type: json['type'] as String? ?? 'Text Clue',
      text: json['text'] as String,
      correctOrder: json['correctOrder'] != null
          ? List<String>.from(json['correctOrder'] as List<dynamic>)
          : null,
      secretCode: json['secretCode'] as String?,
      shortText: json['shortText'] as String?,
      audio: json['audio'] as String?,
      image: json['image'] as String?,
      hints: json['hints'] != null
          ? (json['hints'] as List<dynamic>)
              .map((h) => Hint.fromJson(h as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class Hint {
  final String id;
  final int order;
  final String preview;
  final String text;
  final int minutePenalty;
  final List<String> hintUnlockIds;
  final String? image;
  bool isUsed;

  Hint({
    required this.id,
    required this.order,
    required this.preview,
    required this.text,
    required this.minutePenalty,
    this.hintUnlockIds = const [],
    this.isUsed = false,
    this.image,
  });

  bool isUnlocked(List<Hint> allHints) {
    if (hintUnlockIds.isEmpty) return true;

    return hintUnlockIds.every((unlockId) =>
        allHints.any((hint) => hint.id == unlockId && hint.isUsed));
  }

  factory Hint.fromJson(Map<String, dynamic> json) {
    return Hint(
      id: json['id'] as String,
      order: json['order'] as int,
      preview: json['preview'] as String,
      text: json['text'] as String,
      minutePenalty: json['minutePenalty'] as int,
      hintUnlockIds: json['hintUnlockIds'] != null
          ? List<String>.from(json['hintUnlockIds'] as List<dynamic>)
          : [],
      isUsed: json['isUsed'] as bool? ?? false,
      image: json['image'] as String?,
    );
  }
}

enum ClueStatus { locked, unlocked, inProgress, completed }
