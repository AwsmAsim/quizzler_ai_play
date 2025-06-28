import 'option_model.dart';
import 'question_model.dart';

class MCQ extends Question {
  List<Option> options;
  String correctAnswer;

  MCQ({
    required String id,
    required String questionText,
    required this.options,
    required this.correctAnswer,
    required String explanation,
    required String difficulty,
    required int time,
  }) : super(
    id: id,
    type: 'mcq',
    questionText: questionText,
    explanation: explanation,
    difficulty: difficulty,
    time: time,
  );

  factory MCQ.fromJson(Map<String, dynamic> json) {
    return MCQ(
      id: json['id'],
      questionText: json['question'],
      options: (json['options'] as List)
          .map((option) => Option.fromJson(option))
          .toList(),
      correctAnswer: json['correct_answer'], // Changed from 'correctAnswer'
      explanation: json['explanation'],
      difficulty: json['difficulty'],
      time: json['time'],
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['options'] = options.map((option) => option.toJson()).toList();
    data['correct_answer'] = correctAnswer;
    return data;
  }
}