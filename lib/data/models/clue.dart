class Clue {
  final String id;
  final String label;
  final String type;
  final String text;
  final String category;
  final String? audio;
  final String? image;

  Clue({
    required this.id,
    required this.label,
    required this.type,
    required this.text,
    required this.category,
    this.audio,
    this.image,
  });

  factory Clue.fromJson(Map<String, dynamic> json) {
    return Clue(
        id: json['id'],
        label: json['label'],
        type: json['type'],
        text: json['text'],
        category: json['category'],
        audio: json['audio'],
        image: json['image']);
  }
}
