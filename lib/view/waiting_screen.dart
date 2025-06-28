import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzler/controller/generate_questions_controller.dart';
import 'package:quizzler/utils/constants.dart';
import 'package:quizzler/utils/smooth_navigator.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';
import 'package:quizzler/view/contest_quiz_page.dart';
import 'package:quizzler/view/widgets/rotation_animation.dart';

class WaitingScreen extends StatefulWidget {
  final bool isSoloMode;

  const WaitingScreen({
    Key? key,
    this.isSoloMode = false,
  }) : super(key: key);

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  int _timeLeft = 120; // 2 minutes in seconds
  int _participantCount = 1; // Start with 1 (self)
  Timer? _timer; // Make timer nullable
  Timer? _participantTimer;
  Timer? _startButtonTimer;
  bool _showStartButton = false;
  bool _isButtonEnabled = false;
  StreamSubscription? _quizSubscription;

  // Get the controller
  final GenerateQuestionsController _questionsController =
      Get.find<GenerateQuestionsController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a flag to track if timer is initialized
  bool _isTimerInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupQuizListener();

    // Don't start timer immediately, wait for Firebase data
    if (widget.isSoloMode) {
      _startTimer();
      _isTimerInitialized = true;
    }

    _startButtonTimer = Timer(Duration(seconds: 15), () {
      if (mounted) {
        setState(() {
          _showStartButton = true;
          _isButtonEnabled = true;
        });
      }
    });
  }

  void _setupQuizListener() {
    if (widget.isSoloMode) {
      // For solo mode, just start with default timer
      return;
    }

    final quizId = _questionsController.currentQuizId.value;
    if (quizId.isEmpty) return;

    _quizSubscription = _firestore
        .collection('scheduled_quizzes')
        .doc(quizId)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;

      if (snapshot.exists) {
        final data = snapshot.data()!;

        // Update participant count
        final waitingUsers = data['waiting_users'] as List<dynamic>;
        setState(() {
          _participantCount = waitingUsers.length;
        });

        // Check if quiz has started
        final bool started = data['started'] ?? false;
        if (started) {
          _quizSubscription?.cancel();
          SmoothNavigator.pushReplacement(
              context, ContestQuizPage(quizId: quizId));
        }

        // Update timer based on start_time if available
        if (data['start_time'] != null) {
          final startTime = (data['start_time'] as Timestamp).toDate();
          final now = DateTime.now();

          if (startTime.isAfter(now)) {
            final remainingSeconds = startTime.difference(now).inSeconds;
            if (remainingSeconds > 0) {
              setState(() {
                _timeLeft = remainingSeconds;
                if (!_isTimerInitialized) {
                  _startTimer();
                  _isTimerInitialized = true;
                }
              });
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    // Safely cancel timers
    _timer?.cancel();
    _participantTimer?.cancel();
    _startButtonTimer?.cancel();
    _quizSubscription?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel existing timer if any
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          // If creator, start the quiz
          if (_questionsController.isQuizCreator.value) {
            _startQuizNow();
          }
        }
      });
    });
  }

  String _formatTime(int timeInSeconds) {
    int minutes = timeInSeconds ~/ 60;
    int seconds = timeInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startQuizNow() async {
    try {
      await _questionsController.startQuizNow(context: context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting quiz: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSoloMode
              ? 'Preparing Your Quiz'
              : 'Waiting for Participants',
          style: TextStyle(
            color: context.primaryColor,
            fontSize: 24,
            fontFamily: 'poppins',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Quiz code: ${_questionsController.currentQuizCode.value}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                  fontFamily: 'poppins',
                )),
            SizedBox(height: SizeConstants.defaultPadding * 2),
            Container(
              width: MediaQuery.of(context).size.width,
              child: RotationAnimation(),
            ),
            SizedBox(height: SizeConstants.defaultPadding * 2),
            Text(
              _formatTime(_timeLeft),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: context.primaryColor,
                fontFamily: 'poppins',
              ),
            ),
            SizedBox(height: SizeConstants.defaultPadding),
            if (!widget.isSoloMode) ...[
              Text(
                'Participants Joined',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'poppins',
                ),
              ),
              SizedBox(height: SizeConstants.defaultPadding / 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  _participantCount.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                    fontFamily: 'poppins',
                  ),
                ),
              ),
            ],
            SizedBox(height: SizeConstants.defaultPadding * 2),

            // Start Now button - only visible for creator after 15 seconds
            Obx(() => _questionsController.isQuizCreator.value
                ? AnimatedOpacity(
                    opacity: _showStartButton ? 1.0 : 0.5,
                    duration: Duration(milliseconds: 500),
                    child: Column(
                      children: [
                        Text(
                          "Ready to begin?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                            fontFamily: 'poppins',
                          ),
                        ),
                        SizedBox(height: SizeConstants.defaultPadding),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 56,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: context.primaryColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isButtonEnabled ? _startQuizNow : null,
                            icon: Icon(
                              Icons.play_arrow_rounded,
                              size: 28,
                              color: Colors.white,
                            ),
                            label: Text(
                              "Start Now",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'poppins',
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink()),
            SizedBox(height: SizeConstants.defaultPadding * 2),
          ],
        ),
      ),
    );
  }
}
