import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzler/utils/smooth_navigator.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';
import 'package:quizzler/view/widgets/neumorphic_card.dart';
import 'package:quizzler/utils/constants.dart';

import '../controller/generate_questions_controller.dart';
import '../model/mcq_model.dart';
import '../model/question_model.dart';
import 'mcq_edit_screen.dart';

class QuestionScreen extends StatelessWidget {
  final GenerateQuestionsController questionController =
      Get.put(GenerateQuestionsController());
  final bool withExtraPadding;

  QuestionScreen({this.withExtraPadding = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            if (questionController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            } else if (questionController.questions.isEmpty) {
              return Center(child: Text("No questions available."));
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: questionController.questions.length +
                      (withExtraPadding ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (withExtraPadding &&
                        index == questionController.questions.length) {
                      return SizedBox(height: 80);
                    }

                    final question = questionController.questions[index];
                    return Padding(
                      padding:
                          EdgeInsets.only(bottom: SizeConstants.defaultPadding),
                      child: NeumorphicCard(
                        key: ValueKey(question.id), // Add unique key
                        child: _buildQuestionWidget(question, context),
                      ),
                    );
                  },
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(Question question, BuildContext context) {
    switch (question.type) {
      case 'mcq':
        return _buildMCQWidget(question as MCQ, context);
      default:
        return Text(
          "Unsupported question type.",
          style: TextStyle(
            fontFamily: 'poppins',
            color: context.primaryColor,
          ),
        );
    }
  }

  Widget _buildMCQWidget(MCQ mcq, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Q1: ${mcq.questionText}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'poppins',
                    color: context.primaryColor,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: context.primaryColor),
                onPressed: () {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      MediaQuery.of(context).size.width,
                      kToolbarHeight + 8,
                      MediaQuery.of(context).size.width,
                      kToolbarHeight + 200,
                    ),
                    items: [
                      PopupMenuItem(
                        child: Text(
                          'Edit',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            color: context.primaryColor,
                          ),
                        ),
                        value: 'edit',
                      ),
                      PopupMenuItem(
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            color: Colors.red,
                          ),
                        ),
                        value: 'delete',
                      ),
                    ],
                  ).then((value) {
                    if (value != null) {
                      // Handle the selected option (edit or delete)
                      if (value == 'edit') {
                        // Implement edit logic here
                        _navigateToEditScreen(context, mcq);
                        print("Editing MCQ: ${mcq.questionText}");
                      } else if (value == 'delete') {
                        // Implement delete logic here
                        print("Deleting MCQ: ${mcq.questionText}");
                      }
                    }
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          ...mcq.options.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: option.id == mcq.correctAnswer
                        ? context.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: option.id == mcq.correctAnswer
                          ? context.primaryColor
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      option.text,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        color: option.id == mcq.correctAnswer
                            ? context.primaryColor
                            : Colors.black87,
                      ),
                    ),
                    leading: Radio<String>(
                      focusColor: context.primaryColor,
                      activeColor: context.primaryColor,
                      value: option.id,
                      groupValue: mcq.correctAnswer,
                      onChanged: null,
                    ),
                  ),
                ),
              )),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Explanation:",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  mcq.explanation,
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Difficulty: ${mcq.difficulty}",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'poppins',
                    color: context.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 14,
                      color: context.primaryColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "${mcq.time}s",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'poppins',
                        color: context.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, MCQ mcq) {
    SmoothNavigator.push(
      context,
      MCQEditScreen(mcq: mcq),
    );
  }
}
