class Option {
  final String id; // e.g., "A", "B", "C", "D"
  String text;

  Option({
    required this.id,
    required this.text,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      text: json['text'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
    };
  }
}