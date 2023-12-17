class Quest {
  final String id;
  final String name;
  final String clueFile;
  QuestStatus status;

  Quest({
    required this.id,
    required this.name,
    required this.clueFile,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'clueFile': clueFile,
      'status': status.toString().split('.').last,
    };
  }
}

enum QuestStatus {
  locked,
  unlocked,
  inProgress,
  completed,
}
