class Clue {
  final String id;
  final String code;
  final String label;
  final String type;
  final String text;
  final String category;
  final String? audio;
  final String? image;
  final String? secretCode;
  final String? secretText;
  final String? secretImage;
  final String? shortText;
  final List<dynamic>? correctOrder;
  ClueStatus status = ClueStatus.locked;

  bool get isFound =>
      status == ClueStatus.found || status == ClueStatus.unlocked;
  bool get isUnlocked => status == ClueStatus.unlocked;
  bool get hasSecret => secretCode != null;

  double get clueProgress {
    if (isUnlocked) {
      return 1;
    }

    if (isFound) {
      return 0.5;
    }

    return 0;
  }

  String get getShortText {
    return shortText ?? text;
  }

  String? get displayText {
    if (!isFound) {
      return '???';
    }

    if (isUnlocked && hasSecret) {
      return secretText;
    }

    return text;
  }

  String? get displayImage {
    if (!isFound) {
      return null;
    }

    if (isUnlocked && hasSecret) {
      return secretImage;
    }

    return image;
  }

  Clue({
    required this.id,
    required this.code,
    required this.label,
    required this.type,
    required this.text,
    required this.category,
    this.shortText,
    this.secretCode,
    this.secretText,
    this.secretImage,
    this.audio,
    this.image,
    this.correctOrder,
  });

  factory Clue.fromJson(Map<String, dynamic> json) {
    return Clue(
      id: json['id'],
      code: json['code'],
      label: json['label'],
      type: json['type'],
      text: json['text'],
      category: json['category'],
      audio: json['audio'],
      image: json['image'],
      secretCode: json['secretCode'],
      secretText: json['secretText'],
      secretImage: json['secretImage'],
      shortText: json['shortText'],
      correctOrder: json['correctOrder'],
    );
  }
}

enum ClueStatus {
  locked,
  found,
  unlocked,
}
