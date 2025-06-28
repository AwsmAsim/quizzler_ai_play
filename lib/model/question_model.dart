import 'mcq_model.dart';

abstract class Question {
  final String id;
  final String type; // e.g., "mcq", "fill_in_the_blanks", "match_the_following"
  String questionText;
  String explanation;
  final String difficulty;
  final int time;

  Question({
    required this.id,
    required this.type,
    required this.questionText,
    required this.explanation,
    required this.difficulty,
    required this.time,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    switch (json['type'] ?? "mcq") {
      case 'mcq':
        return MCQ.fromJson(json);
      // case 'fill_in_the_blanks':
      //   return FillInTheBlanks.fromJson(json);
      // case 'match_the_following':
      //   return MatchTheFollowing.fromJson(json);
      default:
        throw Exception("Unsupported question type: ${json['type']}");
    }
  }
  
  // Base toJson method that child classes will extend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'question': questionText,
      'explanation': explanation,
      'difficulty': difficulty,
      'time': time,
    };
  }
}