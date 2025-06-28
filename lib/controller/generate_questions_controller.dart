import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzler/controller/coin_controller.dart';
import 'package:quizzler/controller/contest_quiz_controller.dart';
import 'package:quizzler/model/mcq_model.dart';
import 'package:quizzler/service/generate_question_service.dart';
import 'package:quizzler/utils/custom_snackbar.dart';
import 'package:quizzler/utils/smooth_navigator.dart';
import 'package:quizzler/view/waiting_screen.dart';
import 'package:uuid/uuid.dart';

import '../model/question_model.dart';
import '../view/contest_quiz_page.dart';

class GenerateQuestionsController extends GetxController {
  final GenerateQuestionService generateQuestionService =
      GenerateQuestionService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = Uuid();

  // Initialize CoinController
  final CoinController coinController = Get.find();

  // Reactive variables for state management
  var isLoading = false.obs;
  var questions = <Question>[].obs;
  var currentQuizId = ''.obs;
  var currentContestId = ''.obs;
  var isQuizCreator = true.obs;
  var currentQuizCode = ''.obs;

  // Method to fetch and parse questions (removed coin deduction)
  Future<void> fetchQuestions(BuildContext context,
      {required String topic,
      required String ageGroup,
      required String keywords,
      required String difficultyLevel,
      required String language,
      required int timeLimit,
      int noOfQuestions = 10}) async {
    isLoading(true);
    try {
      final response = await generateQuestionService.generateMCQs(
          topic: topic,
          ageGroup: ageGroup,
          keywords: keywords,
          difficultyLevel: difficultyLevel,
          language: language,
          timeLimit: timeLimit,
          noOfQuestions: noOfQuestions);

      final cleanedJsonString = _removeMarkdownJsonBlock(response);
      log("Cleaned json: $cleanedJsonString");

      final jsonResponse = jsonDecode(cleanedJsonString);
      log("Decoded cleaned json: $jsonResponse");

      if (jsonResponse['questions'] == null) {
        throw Exception(
            'The generated response was not in the expected format. Please try again.');
      }

      final List<dynamic> questionList = jsonResponse['questions'];

      questions
          .assignAll(questionList.map((q) => Question.fromJson(q)).toList());

      if (questions.isEmpty) {
        throw Exception(
            'No questions could be generated for the given criteria. Please try being more specific in the topic description.');
      }

      await createQuiz(context: context, selfParticipation: true);

      if (currentQuizCode.value.isEmpty) {
        throw Exception('Failed to create a quiz session. Please try again.');
      }

      ContestQuizController contestQuizController = Get.find();
      contestQuizController.eachQuestionTimeInSeconds = timeLimit;
      contestQuizController.timeLeft.value = timeLimit;
    } catch (e) {
      log('Error in fetchQuestions: $e');
      // Re-throw the exception to be caught by the UI layer.
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  // Calculate the coin cost based on the number of questions (1 coin per question)
  int calculateCoinCost() {
    return questions.length; // 1 coin per question
  }

  // Deduct coins for the quiz (call after user confirmation)
  // Future<bool> deductCoinsForQuiz(BuildContext context) async {
  //   final cost = calculateCoinCost();
  //   for (int i = 0; i < cost; i++) {
  //     if (!await coinController.deductCoin(context)) {
  //       CustomSnackbar.showError(
  //         context: context,
  //         message: 'Not enough coins to start the quiz. You need $cost coins.',
  //       );
  //       return false;
  //     }
  //   }
  //   return true;
  // }

  String _removeMarkdownJsonBlock(String content) {
    return content.replaceAll("```json", "").replaceAll("```", "").trim();
  }

  String _generateQuizCode() {
    final random = math.Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  Future<void> createQuiz(
      {required BuildContext context, bool selfParticipation = false}) async {
    try {
      if (questions.isEmpty) {
        throw Exception('No questions available to start a quiz');
      }

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('You must be logged in to start a quiz');
      }

      final String quizId = _uuid.v4();
      final String contestId = _uuid.v4();
      final String quizCode = _generateQuizCode();
      currentQuizCode.value = quizCode;
      print("currentQuizCode assigned: ${currentQuizCode.value}");

      currentQuizId.value = quizId;
      currentContestId.value = contestId;
      isQuizCreator.value = true;

      final Timestamp now = Timestamp.now();
      final DateTime startTime =
          now.toDate().add(Duration(minutes: 2, seconds: 10));
      final Timestamp scheduledStartTime = Timestamp.fromDate(startTime);

      print("Questions Generated");
      await _firestore.collection('contests').doc(contestId).set({
        'contest_id': contestId,
        'quiz_id': quizId,
        'questions': questions.map((q) => q.toJson()).toList(),
        'active_users': [],
        'total_participants': [],
        'user_answers': {},
        'current_question': {
          'id': questions.isNotEmpty ? questions[0].id : '',
          'start_time': null,
          'end_time': null,
          'status': 'waiting'
        },
        'leaderboard': [],
        'quiz_status': {
          'started_at': null,
          'current_state': 'waiting',
          'questions_completed': 0,
          'total_questions': questions.length
        },
        'created_at': now,
      });

      await _firestore.collection('scheduled_quizzes').doc(quizId).set({
        'quiz_id': quizId,
        'creator_id': currentUser.uid,
        'creator_name': currentUser.displayName ?? 'Anonymous',
        'onboarding_time': now,
        'start_time': scheduledStartTime,
        'contest_id': contestId,
        'waiting_users': [],
        'started': false,
        'status': 'waiting',
        'quiz_settings': {
          'difficulty':
              questions.isNotEmpty ? questions[0].difficulty : 'Medium',
          'topic': 'Custom Quiz',
          'time_per_question': questions.isNotEmpty ? questions[0].time : 60
        },
        'max_participants': 20,
        'created_at': now,
      });

      await _firestore.collection('quiz_codes').doc(quizCode).set({
        'contest_id': contestId,
        'quiz_id': quizId,
        'created_at': now,
        'expires_at': now.toDate().add(Duration(hours: 24)),
        'creator_id': currentUser.uid,
      });

      if (selfParticipation) {
        await _firestore.collection('contests').doc(contestId).update({
          'current_question.start_time': now,
          'current_question.end_time': Timestamp.fromDate(
              now.toDate().add(Duration(seconds: questions[0].time))),
          'current_question.status': 'active',
          'quiz_status.started_at': now,
          'quiz_status.current_state': 'in_progress',
        });
      }

      print(
          'Quiz created successfully with ID: $quizId and Contest ID: $contestId');
      log('Quiz created successfully with ID: $quizId and Contest ID: $contestId');
    } catch (e) {
      log('Error creating quiz: $e');
      print('Error creating quiz: $e');
      // Re-throw the exception to be caught by the UI layer.
      rethrow;
    }
  }

  Future<void> joinQuiz({
    required BuildContext context,
    required String quizId,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        CustomSnackbar.showError(
          context: context,
          message: 'You must be logged in to join a quiz',
        );
        return;
      }

      final quizDoc =
          await _firestore.collection('scheduled_quizzes').doc(quizId).get();

      if (!quizDoc.exists) {
        CustomSnackbar.showError(
          context: context,
          message: 'Quiz not found',
        );
        return;
      }

      final quizData = quizDoc.data()!;
      final String contestId = quizData['contest_id'];
      final int timePerQuestion = quizData['quiz_settings']['time_per_question'];

      ContestQuizController contestQuizController = Get.find();
      contestQuizController.eachQuestionTimeInSeconds = timePerQuestion;

      currentQuizId.value = quizId;
      currentContestId.value = contestId;
      isQuizCreator.value = quizData['creator_id'] == currentUser.uid;

      final Timestamp now = Timestamp.now();

      await _firestore.collection('scheduled_quizzes').doc(quizId).update({
        'waiting_users': FieldValue.arrayUnion([
          {
            'user_id': currentUser.uid,
            'display_name': currentUser.displayName ?? 'Anonymous',
            'avatar_url': currentUser.photoURL,
            'joined_at': now
          }
        ])
      });

      await _firestore.collection('contests').doc(contestId).update({
        'active_users': FieldValue.arrayUnion([currentUser.uid]),
        'total_participants': FieldValue.arrayUnion([currentUser.uid]),
        'user_answers.${currentUser.uid}': {
          'answers': {},
          'total_points': 0,
          'questions_answered': 0,
          'correct_answers': 0
        },
        'leaderboard': FieldValue.arrayUnion([
          {
            'user_id': currentUser.uid,
            'display_name': currentUser.displayName ?? 'Anonymous',
            'points': 0,
            'rank': 0
          }
        ])
      });

      log('Joined quiz successfully');
    } catch (e) {
      log('Error joining quiz: $e');
      CustomSnackbar.showError(
        context: context,
        message: 'Failed to join quiz: $e',
      );
    }
  }

  Future<void> startQuizNow({required BuildContext context}) async {
    try {
      if (currentQuizId.value.isEmpty || currentContestId.value.isEmpty) {
        throw Exception('No active quiz found to start');
      }

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('You must be logged in to start a quiz');
      }

      // Ensure questions are loaded before starting the quiz
      if (questions.isEmpty) {
        final contestDoc = await _firestore
            .collection('contests')
            .doc(currentContestId.value)
            .get();
        if (contestDoc.exists && contestDoc.data() != null) {
          final contestData = contestDoc.data()!;
          if (contestData['questions'] != null) {
            final List<dynamic> questionList = contestData['questions'];
            questions.assignAll(
                questionList.map((q) => Question.fromJson(q)).toList());
          }
        }
      }

      if (questions.isEmpty) {
        throw Exception('Could not load questions for the quiz.');
      }

      final quizDoc = await _firestore
          .collection('scheduled_quizzes')
          .doc(currentQuizId.value)
          .get();
      if (!quizDoc.exists) {
        throw Exception('Quiz not found');
      }

      final quizData = quizDoc.data()!;
      if (quizData['creator_id'] != currentUser.uid) {
        throw Exception('Only the quiz creator can start the quiz');
      }

      final Timestamp now = Timestamp.now();

      await _firestore
          .collection('scheduled_quizzes')
          .doc(currentQuizId.value)
          .update({
        'started': true,
        'status': 'in_progress',
        'start_time': now,
      });

      await _firestore
          .collection('contests')
          .doc(currentContestId.value)
          .update({
        'current_question.start_time': now,
        'current_question.end_time': Timestamp.fromDate(
            now.toDate().add(Duration(seconds: questions[0].time))),
        'current_question.status': 'active',
        'quiz_status.started_at': now,
        'quiz_status.current_state': 'in_progress',
      });

      log('Quiz started successfully with ID: ${currentQuizId.value}');
    } catch (e) {
      log('Error starting quiz: $e');
      rethrow;
    }
  }

  var selfParticipation = true.obs;

  Future<void> setParticipationMode(bool participate) async {
    selfParticipation.value = participate;

    if (currentQuizId.value.isNotEmpty && currentContestId.value.isNotEmpty) {
      await _updateParticipationInFirestore(participate);
    }
  }

  Future<void> _updateParticipationInFirestore(bool participate) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final now = Timestamp.now();

      if (participate) {
        // Add user to the contest participants
        await _firestore
            .collection('contests')
            .doc(currentContestId.value)
            .update({
          'active_users': FieldValue.arrayUnion([currentUser.uid]),
          'total_participants': FieldValue.arrayUnion([currentUser.uid]),
          'user_answers.${currentUser.uid}': {
            'answers': {},
            'total_points': 0,
            'questions_answered': 0,
            'correct_answers': 0,
          },
          'leaderboard': FieldValue.arrayUnion([
            {
              'user_id': currentUser.uid,
              'display_name': currentUser.displayName ?? 'Anonymous',
              'points': 0,
              'rank': 0
            }
          ])
        });

        // Add user to the waiting list in the scheduled quiz
        await _firestore
            .collection('scheduled_quizzes')
            .doc(currentQuizId.value)
            .update({
          'waiting_users': FieldValue.arrayUnion([
            {
              'user_id': currentUser.uid,
              'display_name': currentUser.displayName ?? 'Anonymous',
              'avatar_url': currentUser.photoURL,
              'joined_at': now,
            }
          ]),
        });
      } else {
        // Remove user from the contest participants
        await _firestore
            .collection('contests')
            .doc(currentContestId.value)
            .update({
          'active_users': FieldValue.arrayRemove([currentUser.uid]),
          'total_participants': FieldValue.arrayRemove([currentUser.uid]),
          'user_answers.${currentUser.uid}': FieldValue.delete(),
          'leaderboard': FieldValue.arrayRemove([
            {
              'user_id': currentUser.uid,
              'display_name': currentUser.displayName ?? 'Anonymous',
              'points': 0,
              'rank': 0
            }
          ])
        });

        // Remove user from the waiting list in the scheduled quiz
        await _firestore
            .collection('scheduled_quizzes')
            .doc(currentQuizId.value)
            .update({
          'waiting_users': FieldValue.arrayRemove([
            {
              'user_id': currentUser.uid,
              'display_name': currentUser.displayName ?? 'Anonymous',
              'avatar_url': currentUser.photoURL,
              'joined_at': now,
            }
          ]),
        });
      }
    } catch (e) {
      log('Error updating participation in Firestore: $e');
    }
  }

  Future<void> joinQuizWithCode({
    required BuildContext context,
    required String code,
  }) async {
    try {
      isLoading(true);

      if (code.length != 6) {
        CustomSnackbar.showError(
          context: context,
          message: 'Please enter a valid 6-digit quiz code',
        );
        return;
      }

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        CustomSnackbar.showError(
          context: context,
          message: 'You must be logged in to join a quiz',
        );
        return;
      }

      final codeDoc = await _firestore.collection('quiz_codes').doc(code).get();

      if (!codeDoc.exists) {
        CustomSnackbar.showError(
          context: context,
          message: 'Invalid quiz code',
        );
        return;
      }

      final codeData = codeDoc.data()!;
      final String quizId = codeData['quiz_id'];
      final String contestId = codeData['contest_id'];
      // final Map<String, dynamic> quizSettings = codeData['quiz_settings'];
      // final String difficulty = quizSettings['difficulty'] ?? "Medium";
      // final int time_per_question = quizSettings['time_per_question'] ?? 120;
      // final String topic = quizSettings['topic'] ?? "Custom Quiz";

      currentQuizId.value = quizId;
      currentContestId.value = contestId;
      isQuizCreator.value = codeData['creator_id'] == currentUser.uid;

      await joinQuiz(context: context, quizId: quizId);

      SmoothNavigator.pushReplacement(context, WaitingScreen());

      log('Joined quiz with code: $code');
    } catch (e) {
      log('Error joining quiz with code: $e');
      CustomSnackbar.showError(
        context: context,
        message: 'Error joining quiz: ${e.toString()}',
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateQuizStartTime() async {
    try {
      if (currentQuizId.value.isEmpty) {
        log('Cannot update start time: No active quiz ID');
        return;
      }

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      if (!isQuizCreator.value) return;

      final Timestamp now = Timestamp.now();
      final DateTime startTime = now.toDate().add(Duration(minutes: 2));
      final Timestamp scheduledStartTime = Timestamp.fromDate(startTime);

      await _firestore
          .collection('scheduled_quizzes')
          .doc(currentQuizId.value)
          .update({
        'start_time': scheduledStartTime,
      });

      log('Quiz start time updated to: ${startTime.toString()}');
    } catch (e) {
      print('Error updating quiz start time: $e');
      log('Error updating quiz start time: $e');
    }
  }

  void updateQuestion(MCQ oldQuestion, MCQ updatedQuestion) {
    print('Updating question - Old ID: ${oldQuestion.id}');
    print('Old question details: $oldQuestion');
    print('Updated question details: $updatedQuestion');

    final index = questions.indexWhere((q) => q.id == oldQuestion.id);
    print('Found question at index: $index');

    if (index != -1) {
      questions[index] = updatedQuestion;
      questions.refresh();
      print('Question updated successfully');
    } else {
      print('Question not found in list');
    }
  }

  Future<void> fetchQuestionsForTesting(BuildContext context,
      {required String topic,
      required String ageGroup,
      required String keywords,
      required String difficultyLevel,
      required String language,
      required int timeLimit,
      int noOfQuestions = 10}) async {
    isLoading(true);
    try {
      // This now calls the testing-specific service method
      await generateQuestionService.generateMCQsForTesting(
          topic: topic,
          ageGroup: ageGroup,
          keywords: keywords,
          difficultyLevel: difficultyLevel,
          language: language,
          timeLimit: timeLimit,
          noOfQuestions: noOfQuestions);

    } catch (e) {
      log('Error in fetchQuestionsForTesting: $e');
      // Re-throw the exception to be caught by the UI layer.
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  void resetQuizState() {
    currentQuizId.value = '';
    currentContestId.value = '';
    currentQuizCode.value = '';
    isQuizCreator.value = true;
  }
}
