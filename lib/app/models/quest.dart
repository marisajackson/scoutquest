class Quest {
  final String id;
  final String name;
  final String clueFile;
  final DateTime? startTime;
  final DateTime? endTime;
  QuestStatus status;

  Quest({
    required this.id,
    required this.name,
    required this.clueFile,
    required this.status,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'clueFile': clueFile,
      'status': status.toString().split('.').last,
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
