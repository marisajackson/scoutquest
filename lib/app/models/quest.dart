class Quest {
  final String id;
  final String name;
  final String clueFile;

  Quest({
    required this.id,
    required this.name,
    required this.clueFile,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'clueFile': clueFile,
    };
  }
}
