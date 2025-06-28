import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzler/controller/contest_quiz_controller.dart';
import 'package:quizzler/controller/generate_questions_controller.dart';
import 'package:quizzler/utils/constants.dart';
import 'package:quizzler/utils/smooth_navigator.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';
import 'package:quizzler/view/generated_questions_page.dart';
import 'package:quizzler/view/home_page.dart';
import 'package:quizzler/view/question_generator_form.dart';

class QuizCompletedScreen extends StatefulWidget {
  final String contestId;

  const QuizCompletedScreen({
    Key? key,
    required this.contestId,
  }) : super(key: key);

  @override
  State<QuizCompletedScreen> createState() => _QuizCompletedScreenState();
}

class _QuizCompletedScreenState extends State<QuizCompletedScreen> {
  final ContestQuizController _controller = Get.find();
  bool _isLoading = true;
  List<Map<String, dynamic>> _finalLeaderboard = [];

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
    _loadFinalLeaderboard();
  }

  Future<void> _loadFinalLeaderboard() async {
    try {
      await _controller.fetchTopLeaderboard();
      setState(() {
        _finalLeaderboard = _controller.topLeaderboard;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading final leaderboard: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: _responsivePadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: _scaleSize(context, 80),
                color: context.primaryColor,
              ),
              SizedBox(
                  height: _scaleSize(context, SizeConstants.defaultPadding)),
              Text(
                'Quiz Completed!',
                style: TextStyle(
                  fontSize: _scaleSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                  fontFamily: 'poppins',
                ),
              ),
              SizedBox(
                  height:
                      _scaleSize(context, SizeConstants.defaultPadding * 2)),

              // Final Leaderboard
              Text(
                'Final Leaderboard',
                style: TextStyle(
                  fontSize: _scaleSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'poppins',
                ),
              ),
              SizedBox(
                  height: _scaleSize(context, SizeConstants.defaultPadding)),

              // Leaderboard content
              _isLoading
                  ? CircularProgressIndicator(
                      color: context.primaryColor,
                    )
                  : Expanded(
                      child: _finalLeaderboard.isEmpty
                          ? Center(
                              child: Text(
                                'No leaderboard data available',
                                style: TextStyle(
                                  fontSize: _scaleSize(context, 16),
                                  color: Colors.grey,
                                  fontFamily: 'poppins',
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _finalLeaderboard.length,
                              itemBuilder: (context, index) {
                                final entry = _finalLeaderboard[index];
                                final rank = index + 1;
                                final username = entry['user_display_name'] ??
                                    'Unknown User';
                                final points = entry['points'] ?? 0;

                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.only(
                                      bottom: _scaleSize(context, 8)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        _scaleSize(context, 12)),
                                  ),
                                  child: Container(
                                    constraints: BoxConstraints(
                                      minHeight: _scaleSize(
                                          context, 56), // Scaled card height
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        radius: _scaleSize(context, 20),
                                        backgroundColor: _getLeaderColor(rank),
                                        child: Text(
                                          '$rank',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: _scaleSize(context, 16),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        username,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'poppins',
                                          fontSize: _scaleSize(context, 16),
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // Prevent overflow
                                      ),
                                      trailing: Text(
                                        '$points pts',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: context.primaryColor,
                                          fontFamily: 'poppins',
                                          fontSize: _scaleSize(context, 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

              SizedBox(
                  height: _scaleSize(context, SizeConstants.defaultPadding)),
              Container(
                constraints: BoxConstraints(
                  minHeight: _scaleSize(context, 56), // Scaled button height
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final contestController = Get.find<ContestQuizController>();
                    final generateController =
                        Get.find<GenerateQuestionsController>();

                    contestController.resetQuizState();
                    generateController.resetQuizState();

                    SmoothNavigator.pushAndRemoveUntil(
                        context, QuestionGeneratorForm(), (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, _scaleSize(context, 56)),
                    padding: EdgeInsets.symmetric(
                      horizontal: _scaleSize(context, 32),
                      vertical: _scaleSize(context, 16),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(_scaleSize(context, 28)),
                    ),
                  ),
                  child: Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: _scaleSize(context, 16),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLeaderColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.blueGrey.shade300; // Silver
      case 3:
        return Colors.brown.shade300; // Bronze
      default:
        return Colors.blue.shade700;
    }
  }
}
