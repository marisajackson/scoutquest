class Quest {
  final String id;
  final String name;
  final String clueFile;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? clueStep;
  QuestStatus status;

  Quest({
    required this.id,
    required this.name,
    required this.clueFile,
    required this.status,
    this.clueStep = '0',
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'clueFile': clueFile,
      'status': status.toString().split('.').last,
      'clueStep': clueStep.toString(),
      'startTime': startTime?.toIso8601String(),
    };
  }
}

enum QuestStatus {
  locked,
  unlocked,
  inProgress,
  completed,
  submitted,
}
