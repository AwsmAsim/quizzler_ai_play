import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzler/controller/contest_quiz_controller.dart';
import 'package:quizzler/controller/generate_questions_controller.dart';
import 'package:quizzler/model/question_model.dart';
import 'package:quizzler/utils/constants.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';
import 'package:quizzler/view/quiz_completed_screen.dart';
import 'package:quizzler/view/widgets/leaderboard_overlay.dart';
import '../model/mcq_model.dart';
import 'package:quizzler/view/widgets/option_card.dart';

class ContestQuizPage extends StatefulWidget {
  final String quizId;

  const ContestQuizPage({
    Key? key,
    required this.quizId,
  }) : super(key: key);

  @override
  _ContestQuizPageState createState() => _ContestQuizPageState();
}

class _ContestQuizPageState extends State<ContestQuizPage> {
  final ContestQuizController _controller = Get.put(ContestQuizController());
  final GenerateQuestionsController _questionsController = Get.find();

  // Helper method to scale sizes based on screen width
  double _scaleSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Scale factor: 1 for iPhone (width ~390), up to 1.5 for iPad (width ~810)
    final scaleFactor = (screenWidth / 390).clamp(1.0, 1.5);
    return baseSize * scaleFactor;
  }

  // Responsive padding based on screen size
  EdgeInsets _responsivePadding(BuildContext context) {
    final basePadding = SizeConstants.defaultPadding; // Assuming 16.0
    final scaledPadding = _scaleSize(context, basePadding);
    return EdgeInsets.all(scaledPadding);
  }

  @override
  void initState() {
    super.initState();
    _controller.setupContestListener();

    ever(_controller.isQuizCompleted, (bool completed) {
      if (completed && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            print("Moving to QuizCompletedScreen");
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => QuizCompletedScreen(
                  contestId: _questionsController.currentContestId.value,
                ),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.cancelOperations();
    super.dispose();
  }

  void _handleOptionSelection(String optionId) {
    if (mounted) {
      print("Option selected");
      _controller.selectOption(optionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_controller.loading.value,
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          title: Text(
            'Live Quiz',
            style: TextStyle(
              color: context.primaryColor,
              fontSize: _scaleSize(context, 24),
              fontFamily: 'poppins',
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    _scaleSize(context, 16).clamp(12.0, 24.0), // Cap padding
              ),
              child: Center(
                child: GetX<ContestQuizController>(
                  builder: (controller) => ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _scaleSize(context, 100)
                          .clamp(80.0, 120.0), // Prevent overflow
                    ),
                    child: Text(
                      'Q${controller.currentQuestionIndex.value + 1}/${_questionsController.questions.length}',
                      style: TextStyle(
                        color: context.primaryColor,
                        fontSize: _scaleSize(context, 16),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'poppins',
                      ),
                      overflow:
                          TextOverflow.ellipsis, // Handle long question counts
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Timer bar
                GetX<ContestQuizController>(
                  builder: (controller) => Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: _scaleSize(context, 48), // Scaled height
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: _scaleSize(context, 8),
                      horizontal: _scaleSize(context, 16),
                    ),
                    color: context.primaryColor.withOpacity(0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              color: context.primaryColor,
                              size: _scaleSize(context, 24),
                            ),
                            SizedBox(width: _scaleSize(context, 8)),
                            Text(
                              controller.formatTime(controller.timeLeft.value),
                              style: TextStyle(
                                fontSize: _scaleSize(context, 18),
                                fontWeight: FontWeight.bold,
                                color: context.primaryColor,
                                fontFamily: 'poppins',
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: Obx(() => Text(
                            '${_controller.answeredParticipantsCount.value} / ${_controller.totalParticipants.value} Answered',
                            style: TextStyle(
                              fontSize: _scaleSize(context, 16),
                              fontWeight: FontWeight.bold,
                              color: context.primaryColor,
                              fontFamily: 'poppins',
                            ),
                            overflow: TextOverflow.ellipsis, // Prevent overflow
                          )),
                        ),
                        Flexible(
                          child: Text(
                            'Points: ${controller.timeLeft.value * 10}',
                            style: TextStyle(
                              fontSize: _scaleSize(context, 16),
                              fontWeight: FontWeight.bold,
                              color: context.primaryColor,
                              fontFamily: 'poppins',
                            ),
                            overflow: TextOverflow.ellipsis, // Prevent overflow
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Question section
                Expanded(
                  child: SingleChildScrollView(
                    padding: _responsivePadding(context),
                    child: Obx(() {
                      final currentQuestion = _controller.currentQuestion.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentQuestion?.questionText ??
                                "Waiting for question...",
                            style: TextStyle(
                              fontSize: _scaleSize(context, 20),
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontFamily: 'poppins',
                            ),
                          ),
                          SizedBox(
                              height: _scaleSize(
                                  context, SizeConstants.defaultPadding)),

                          // Options
                          if (currentQuestion != null &&
                              currentQuestion is MCQ) ...[
                            ...currentQuestion.options.map((option) {
                              final bool isSelected =
                                  _controller.selectedOption.value == option.id;
                              final bool showCorrect = _controller
                                      .hasAnswered.value &&
                                  option.id == currentQuestion.correctAnswer;

                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: _scaleSize(context, 12)),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: _scaleSize(context,
                                        56), // Scaled option card height
                                  ),
                                  child: OptionCard(
                                    option: option,
                                    isSelected: isSelected,
                                    showCorrect: showCorrect,
                                    onTap: () =>
                                        _handleOptionSelection(option.id),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],

                          // Explanation
                          if (_controller.hasAnswered.value &&
                              currentQuestion != null) ...[
                            SizedBox(
                                height: _scaleSize(
                                    context, SizeConstants.defaultPadding)),
                            Container(
                              padding: EdgeInsets.all(_scaleSize(context, 16)),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    _scaleSize(context, 12)),
                                border: Border.all(
                                    color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Explanation:',
                                    style: TextStyle(
                                      fontSize: _scaleSize(context, 16),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                      fontFamily: 'poppins',
                                    ),
                                  ),
                                  SizedBox(height: _scaleSize(context, 8)),
                                  Text(
                                    currentQuestion.explanation,
                                    style: TextStyle(
                                      fontSize: _scaleSize(context, 14),
                                      color: Colors.black87,
                                      fontFamily: 'poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    }),
                  ),
                ),

                // Next question button
                Obx(() {
                  if (_questionsController.isQuizCreator.value &&
                      _controller.hasAnswered.value) {
                    return Padding(
                      padding: _responsivePadding(context),
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight:
                              _scaleSize(context, 56), // Scaled button height
                        ),
                        child: ElevatedButton(
                          onPressed: _controller.onNextButtonPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize:
                                Size(double.infinity, _scaleSize(context, 56)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  _scaleSize(context, 28)),
                            ),
                          ),
                          child: Text(
                            'Next Question',
                            style: TextStyle(
                              fontSize: _scaleSize(context, 18),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'poppins',
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                }),
              ],
            ),

            // Loading overlay
            Obx(() {
              if (_controller.loading.value ||
                  _controller.currentQuestion.value == null) {
                return Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(_scaleSize(context, 20)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(_scaleSize(context, 10)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: context.primaryColor,
                          ),
                          SizedBox(height: _scaleSize(context, 16)),
                          Text(
                            _controller.loading.value
                                ? "Processing..."
                                : "Loading Question...",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: _scaleSize(context, 16),
                              fontFamily: 'poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }),

            // Leaderboard overlay
            Obx(() {
              if (_controller.showLeaderboard.value) {
                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('contest_answers')
                      .where('contest_id',
                          isEqualTo:
                              _questionsController.currentContestId.value)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: context.primaryColor,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      print("Error fetching leaderboard: ${snapshot.error}");
                      return Center(
                        child: Text(
                          "Error loading leaderboard",
                          style: TextStyle(
                            fontSize: _scaleSize(context, 16),
                            fontFamily: 'poppins',
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return LeaderboardOverlay(
                        leaderboardData: [],
                      );
                    }

                    List<Map<String, dynamic>> leaderboardEntries = [];

                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final participantId = data['user_id'] as String;
                      final totalPoints = data['total_points'] as int;
                      final userDisplayName =
                          data['user_display_name'] as String;

                      leaderboardEntries.add({
                        'user_display_name': userDisplayName,
                        'user_id': participantId,
                        'points': totalPoints,
                        'timestamp': DateTime.now().toUtc(),
                      });
                    }
                    print("Adding entry in database");
                    print(leaderboardEntries);

                    leaderboardEntries.sort((a, b) =>
                        (b['points'] as int).compareTo(a['points'] as int));

                    return LeaderboardOverlay(
                      leaderboardData: leaderboardEntries,
                    );
                  },
                );
              }
              return SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
