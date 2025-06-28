import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzler/controller/generate_questions_controller.dart';
import 'package:quizzler/model/option_model.dart';

import '../model/mcq_model.dart';

class MCQEditScreen extends StatefulWidget {
  final MCQ mcq;

  MCQEditScreen({required this.mcq});

  @override
  _MCQEditScreenState createState() => _MCQEditScreenState();
}

class _MCQEditScreenState extends State<MCQEditScreen> {
  late TextEditingController _questionController;
  late TextEditingController _optionControllers1,
      _optionControllers2,
      _optionControllers3,
      _optionControllers4;
  late TextEditingController _explanationController;
  // Controllers for options, explanation, difficulty, time, etc.

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.mcq.questionText);
    _optionControllers1 =
        TextEditingController(text: widget.mcq.options[0].text);
    _optionControllers2 =
        TextEditingController(text: widget.mcq.options[1].text);
    _optionControllers3 =
        TextEditingController(text: widget.mcq.options[2].text);
    _optionControllers4 =
        TextEditingController(text: widget.mcq.options[3].text);
    _explanationController =
        TextEditingController(text: widget.mcq.explanation);
    // Initialize other controllers with MCQ data
  }

  @override
  void dispose() {
    _questionController.dispose();
    // Dispose other controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit MCQ'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF6E41E2)),
        titleTextStyle: TextStyle(color: Color(0xFF6E41E2)),
        elevation: 0, // Remove AppBar Shadow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextFieldWithShadow(
                controller: _questionController,
                labelText: 'Question',
              ),
              // Options
              for (int index = 0; index < 4; index++)
                _buildTextFieldWithShadow(
                  controller: TextEditingController(
                      text: widget.mcq.options[index].text),
                  labelText: 'Option ${index + 1}',
                ),
              // ...widget.mcq.options.map((option, index) =>
              //     _buildTextFieldWithShadow(
              //       controller: TextEditingController(text: option.text),
              //       labelText: 'Option ${index + 1}',
              //     )
              // ).toList(),
              // Explanation
              _buildTextFieldWithShadow(
                controller: TextEditingController(text: widget.mcq.explanation),
                labelText: 'Explanation',
                maxLines: 3,
              ),
              // Difficulty
              // _buildTextFieldWithShadow(
              //   controller: TextEditingController(text: widget.mcq.difficulty),
              //   labelText: 'Difficulty',
              // ),
              // Time
              // _buildTextFieldWithShadow(
              //   controller: TextEditingController(text: widget.mcq.time),
              //   labelText: 'Time',
              // ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Create a copy of the original MCQ
                  final updatedMCQ = MCQ(
                    id: widget.mcq.id,
                    questionText: _questionController.text,
                    options: [
                      Option(id: 'A', text: _optionControllers1.text),
                      Option(id: 'B', text: _optionControllers2.text),
                      Option(id: 'C', text: _optionControllers3.text),
                      Option(id: 'D', text: _optionControllers4.text),
                    ],
                    correctAnswer:
                        widget.mcq.correctAnswer, // Preserve correct answer
                    explanation: _explanationController.text,
                    difficulty: widget.mcq.difficulty,
                    time: widget.mcq.time,
                  );

                  // Update through controller
                  final controller = Get.find<GenerateQuestionsController>();
                  controller.updateQuestion(widget.mcq, updatedMCQ);

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6E41E2), // Use your primary color
                ),
                child: Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithShadow({
    required TextEditingController controller,
    required String labelText,
    int? maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        // Use a Container for shadow
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0), // Optional border radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color
              blurRadius: 5, // Shadow blur radius
              offset: Offset(0, 3), // Shadow offset
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none, // Remove default border
            contentPadding: EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
}
