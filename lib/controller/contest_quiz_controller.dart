import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzler/controller/auth_controller.dart';
import 'package:quizzler/controller/generate_questions_controller.dart';
import 'package:quizzler/model/answer_result.dart';
import 'package:quizzler/model/question_model.dart';
import 'package:quizzler/model/mcq_model.dart';
import 'package:quizzler/utils/smooth_navigator.dart';
import 'package:quizzler/view/quiz_completed_screen.dart';
import 'dart:math' as math;

class ContestQuizController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GenerateQuestionsController _questionsController = Get.find();

  // Observable variables
  final currentQuestion = Rxn<Question>();
  final currentQuestionIndex = 0.obs;
  int eachQuestionTimeInSeconds = 0;
  RxInt timeLeft = 180.obs;
  final selectedOption = RxnString();
  final hasAnswered = false.obs;
  final leaderboard = <Map<String, dynamic>>[].obs;
  final loading = false.obs;
  final answeredParticipantsCount = 0.obs;
  final totalParticipants = 0.obs;

  // Private variables
  Timer? _timer;
  StreamSubscription? _contestSubscription;

  @override
  void onClose() {
    _contestSubscription?.cancel();
    _timer?.cancel();
    super.onClose();
  }

  void onInit() {
    super.onInit();
    setupContestListener();
    startTimer();
  }

  // void setupContestListener() {
  //   try {
  //     print("Setting up contest listener...");
  //     loading.value = true;
  //     final contestId = _questionsController.currentContestId.value;
  //     print("Contest ID: $contestId"); // Check if contest ID is valid
  //     if (contestId.isEmpty) return;

  //     _contestSubscription = _firestore
  //         .collection('contests')
  //         .doc(contestId)
  //         .snapshots()
  //         .listen((snapshot) {
  //       try {
  //         print("Processing constests snapshot..."); // Debug print
  //         print(
  //             "Snapshot exists: ${snapshot.exists}"); // Check if document exists
  //         if (!snapshot.exists) return;

  //         final data = snapshot.data()!;
  //         print(
  //             "Current question data: ${data['current_question']}"); // Check question data

  //         final currentQuestionData = data['current_question'];
  //         final String currentQuestionId = currentQuestionData['id'];

  //         // Check if this is a new question (different from the current one)
  //         final bool isNewQuestion = currentQuestion.value == null ||
  //             currentQuestion.value!.id != currentQuestionId;

  //         if (isNewQuestion) {
  //           print("New question detected, updating UI");
  //           // Reset selection state when question changes
  //           selectedOption.value = null;
  //           hasAnswered.value = false;
  //           timeLeft.value = 180; // Reset timer for new question

  //           final List<dynamic> questionsData = data['questions'];
  //           final questions =
  //               questionsData.map((q) => Question.fromJson(q)).toList();
  //           print(
  //               "Questions length: ${questions.length}"); // Check questions array

  //           final questionIndex =
  //               questions.indexWhere((q) => q.id == currentQuestionId);
  //           print(
  //               "Question index: $questionIndex"); // Check if question is found

  //           if (questionIndex != -1) {
  //             currentQuestion.value = questions[questionIndex];
  //             print(
  //                 "Current question set: ${currentQuestion.value?.questionText}"); // Verify assignment
  //             currentQuestionIndex.value = questionIndex;
  //           }
  //         }

  //         // Also check if quiz is completed
  //         final currentState = data['quiz_status']?['current_state'];
  //         if (currentState == 'completed') {
  //           print("Quiz is completed, state updated");
  //           isQuizCompleted.value = true;
  //         }
  //       } catch (e) {
  //         print("Error processing snapshot: $e"); // Debug print
  //       }
  //     });
  //   } catch (e) {
  //     print("Error setting up contest listener: $e"); // Debug print
  //   } finally {
  //     loading.value = false;
  //     print("Contest listener setup completed"); // Debug print
  //   }
  // }

  // Add these observable variables near your other observable variables
  final showLeaderboard = false.obs;
  final topLeaderboard = <Map<String, dynamic>>[].obs;

  // Modify startTimer to show leaderboard when timer ends
  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        _timer?.cancel();
        if (_questionsController.isQuizCreator.value) {
          // Show leaderboard before moving to next question
          showLeaderboardAndContinue();
        } else {
          // For non-quiz creators, just wait for updates from Firestore
          print("Timer ended for participant, waiting for quiz creator action");
        }
      }
    });
  }

  // New method to show leaderboard and continue after delay
  Future<void> showLeaderboardAndContinue() async {
    try {
      // Fetch and update leaderboard
      await fetchTopLeaderboard();

      // Show leaderboard
      showLeaderboard.value = true;

      // Update Firestore to notify all users to show leaderboard
      final contestId = _questionsController.currentContestId.value;
      await _firestore.collection('contests').doc(contestId).update({
        'quiz_status.show_leaderboard': true,
      });

      // Wait 5 seconds then move to next question
      await Future.delayed(Duration(seconds: 5));

      // Hide leaderboard
      showLeaderboard.value = false;

      // Update Firestore to notify all users to hide leaderboard
      await _firestore.collection('contests').doc(contestId).update({
        'quiz_status.show_leaderboard': false,
      });

      // Move to next question if not completed
      if (!isQuizCompleted.value) {
        moveToNextQuestion();
      }
    } catch (e) {
      print('Error showing leaderboard: $e');
    }
  }

  // New method to fetch top leaderboard
  Future<void> fetchTopLeaderboard() async {
    try {
      final contestId = _questionsController.currentContestId.value;
      if (contestId.isEmpty) return;

      final contestDoc =
          await _firestore.collection('contests').doc(contestId).get();
      if (!contestDoc.exists) return;

      final List<dynamic> allEntries = contestDoc.data()?['leaderboard'] ?? [];

      // Convert to List<Map<String, dynamic>> and sort by points (descending)
      final sortedEntries = List<Map<String, dynamic>>.from(allEntries)
        ..sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));

      // Get top 5 entries
      final topEntries = sortedEntries.take(5).toList();

      // Fetch usernames for each entry
      for (var entry in topEntries) {
        final userId = entry['user_id'] as String;
        final userDoc =
            await _firestore.collection('user_details').doc(userId).get();
        if (userDoc.exists) {
          // here we are using display name cause this is getting loaded from users table and not user answers table
          entry['username'] = userDoc.data()?['display_name'] ?? 'Unknown User';
        } else {
          entry['username'] = 'Unknown User';
        }
      }

      print("top leaderboard updated");

      // Update observable list
      topLeaderboard.assignAll(topEntries);
    } catch (e) {
      print('Error fetching top leaderboard: $e');
    }
  }

  // Modify setupContestListener to detect leaderboard state changes
  // Modify setupContestListener to detect quiz completion and save contest records
  void setupContestListener() {
    try {
      print("Setting up contest listener...");
      loading.value = true;
      final contestId = _questionsController.currentContestId.value;
      print("Contest ID: $contestId");
      if (contestId.isEmpty) return;

      _contestSubscription = _firestore
          .collection('contests')
          .doc(contestId)
          .snapshots()
          .listen((snapshot) {
        try {
          print("Processing contests snapshot...");
          if (!snapshot.exists) return;

          final data = snapshot.data()!;
          // final questions = Question.fromJson(data['questions']);

          // Check for leaderboard visibility changes
          final bool shouldShowLeaderboard =
              data['quiz_status']?['show_leaderboard'] ?? false;
          if (shouldShowLeaderboard != showLeaderboard.value) {
            print("Leaderboard visibility changed to: $shouldShowLeaderboard");
            showLeaderboard.value = shouldShowLeaderboard;

            // If leaderboard should be shown, fetch the data
            if (shouldShowLeaderboard) {
              fetchTopLeaderboard();
            }
          }

          final currentQuestionData = data['current_question'];
          final String currentQuestionId = currentQuestionData['id'];

          // Update total participants
          final List<dynamic> participants = data['total_participants'] ?? [];
          totalParticipants.value = participants.length;

          // Update answered count
          final Map<String, dynamic> userAnswers = data['user_answers'] ?? {};
          int answeredCount = 0;
          userAnswers.forEach((key, value) {
            if (value['answers'] != null && value['answers'][currentQuestionId] != null) {
              answeredCount++;
            }
          });
          answeredParticipantsCount.value = answeredCount;

          // Check if this is a new question (different from the current one)
          final bool isNewQuestion = currentQuestion.value == null ||
              currentQuestion.value!.id != currentQuestionId;

          GenerateQuestionsController questionsController = Get.find();
          // questionsController.questions = data['questions'].map((q) => Question.fromJson(q)).toList();

          if (isNewQuestion) {
            print("New question detected, updating UI");
            // Reset selection state when question changes
            selectedOption.value = null;
            hasAnswered.value = false;
            resetAttemptTime(); // Reset timer for new question
            startTimer();

            final List<dynamic> questionsData = data['questions'];
            final questions =
                questionsData.map((q) => Question.fromJson(q)).toList();
            print(
                "Questions length: ${questions.length}"); // Check questions array
            questionsController.questions.value = questions;

            final questionIndex =
                questions.indexWhere((q) => q.id == currentQuestionId);
            print(
                "Question index: $questionIndex"); // Check if question is found

            if (questionIndex != -1) {
              currentQuestion.value = questions[questionIndex];
              print(
                  "Current question set: ${currentQuestion.value?.questionText}"); // Verify assignment
              currentQuestionIndex.value = questionIndex;
            }
          }

          // Also check if quiz is completed
          final currentState = data['quiz_status']?['current_state'];
          if (currentState == 'completed' && !isQuizCompleted.value) {
            print("Quiz is completed, state updated");
            isQuizCompleted.value = true;
            _timer?.cancel(); // Stop timer on quiz completion

            // Save contest record to user_details when quiz is completed
            _saveContestRecord(contestId);
          }
        } catch (e) {
          print("Error processing snapshot: $e");
        }
      });
    } catch (e) {
      print("Error setting up contest listener: $e");
    } finally {
      loading.value = false;
    }
  }

  // New method to save contest record to user_details
  void _saveContestRecord(String contestId) {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    print("Saving contest record for user: ${currentUser.uid}");

    // This operation can run in the background without awaiting
    _firestore.runTransaction((transaction) async {
      try {
        // Get user's contest answers
        final userAnswersDoc = await transaction.get(_firestore
            .collection('contest_answers')
            .doc('${contestId}_${currentUser.uid}'));

        if (!userAnswersDoc.exists) {
          print("No contest answers found for user");
          return;
        }

        final userAnswers = userAnswersDoc.data()!;
        final int totalPoints = userAnswers['total_points'] ?? 0;
        final int questionsAnswered = userAnswers['questions_answered'] ?? 0;
        final int correctAnswers = userAnswers['correct_answers'] ?? 0;

        // Get contest details
        final contestDoc = await transaction
            .get(_firestore.collection('contests').doc(contestId));

        if (!contestDoc.exists) {
          print("Contest document not found");
          return;
        }

        final contestData = contestDoc.data()!;
        final String contestName = contestData['name'] ?? 'Unnamed Contest';
        final Timestamp contestCreatedAt =
            contestData['created_at'] ?? Timestamp.now();

        // Calculate user's rank in leaderboard
        final List<dynamic> leaderboardEntries =
            contestData['leaderboard'] ?? [];
        final sortedEntries = List<Map<String, dynamic>>.from(
            leaderboardEntries)
          ..sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));

        int userRank = 0;
        for (int i = 0; i < sortedEntries.length; i++) {
          if (sortedEntries[i]['user_id'] == currentUser.uid) {
            userRank = i + 1;
            break;
          }
        }

        // Get user_details document
        final userDetailsDoc = await transaction
            .get(_firestore.collection('user_details').doc(currentUser.uid));

        // Prepare contest record
        final contestRecord = {
          'contest_id': contestId,
          'contest_code': _questionsController.currentQuizCode.value,
          'contest_name': contestName,
          'completed_at': Timestamp.now(),
          'contest_created_at': contestCreatedAt,
          'total_points': totalPoints,
          'questions_answered': questionsAnswered,
          'correct_answers': correctAnswers,
          'accuracy_percentage': questionsAnswered > 0
              ? (correctAnswers / questionsAnswered * 100).round()
              : 0,
          'leaderboard_rank': userRank,
          'total_participants': sortedEntries.length,
        };

        // Update user_details document
        if (userDetailsDoc.exists) {
          // Get existing contest records or create empty list
          final userData = userDetailsDoc.data()!;
          final List<dynamic> existingRecords =
              userData['contest_records'] ?? [];

          // Add new record to the list
          transaction.update(
              _firestore.collection('user_details').doc(currentUser.uid), {
            'contest_records': FieldValue.arrayUnion([contestRecord])
          });
        } else {
          // Create new user_details document with contest record
          transaction
              .set(_firestore.collection('user_details').doc(currentUser.uid), {
            'contest_records': [contestRecord]
          });
        }

        print("Contest record saved successfully");
      } catch (e) {
        print("Error saving contest record: $e");
      }
    }).catchError((error) {
      print("Transaction failed: $error");
    });
  }

  // Modify moveToNextQuestion to handle the Next button press
  void onNextButtonPressed() {
    if (_questionsController.isQuizCreator.value && hasAnswered.value) {
      _timer?.cancel();
      showLeaderboardAndContinue();
    }
  }

  void selectOption(String optionId) {
    if (hasAnswered.value) return;

    selectedOption.value = optionId;
    hasAnswered.value = true;
    print("Submitting answer");
    submitAnswer(optionId);
  }

  Future<void> submitAnswer(String optionId) async {
    try {
      loading.value = true;
      final User? currentUser = _auth.currentUser;
      if (currentUser == null || currentQuestion.value == null) return;

      final contestId = _questionsController.currentContestId.value;
      if (contestId.isEmpty) return;

      // Check if answer is correct and calculate points
      final AnswerResult result = _evaluateAnswer(optionId);

      // Save user's answer to Firestore
      await _saveUserAnswer(contestId, currentUser.uid, optionId, result);

      // Update leaderboard if user is quiz creator
      if (_questionsController.isQuizCreator.value) {
        await _updateLeaderboard(
            contestId,
            currentUser.uid,
            currentUser.displayName ??
                "UnknownUser" + math.Random().nextInt(9999999).toString(),
            result.points);

        // Add a delay before moving to next question
        // Future.delayed(Duration(seconds: 3), () {
        //   if (!isQuizCompleted.value) {
        //     moveToNextQuestion();
        //   }
        // });
      }

      print("Answer submission completed for contest id: $contestId");
    } catch (e) {
      print('Error submitting answer: $e');
    } finally {
      loading.value = false;
    }
  }

  // Evaluates the answer and returns result with correctness and points
  AnswerResult _evaluateAnswer(String optionId) {
    bool isCorrect = false;
    if (currentQuestion.value!.type == "mcq") {
      final mcqQuestion = currentQuestion.value as MCQ;
      isCorrect = optionId == mcqQuestion.correctAnswer;
    }

    final int points = isCorrect ? (timeLeft.value * 10) : 0;
    return AnswerResult(isCorrect: isCorrect, points: points);
  }

  // Saves the user's answer to Firestore
  Future<void> _saveUserAnswer(String contestId, String userId, String optionId,
      AnswerResult result) async {
    final userAnswerRef =
        _firestore.collection('contest_answers').doc('${contestId}_${userId}');

    try {
      // Use a transaction for atomic update
      await _firestore.runTransaction((transaction) async {
        final userAnswerDoc = await transaction.get(userAnswerRef);

        AuthController authController = Get.find();

        if (!userAnswerDoc.exists) {
          print("Creating initial answer document");
          print(
              "authController?.currentUser.value?.displayName: ${authController?.currentUser.value?.displayName}");
          print("email: ${authController?.currentUser.value?.email}");

          transaction.set(userAnswerRef, {
            'contest_id': contestId,
            'user_id': userId,
            'user_display_name':
                (authController?.currentUser.value?.displayName) ??
                    (authController?.currentUser.value?.email ?? "UnknownUser"),
            'total_points': 0,
            'questions_answered': 0,
            'correct_answers': 0,
            'answers': {},
            'created_at': FieldValue.serverTimestamp(),
          });
        }

        print("Updating answer document");

        // Calculate new values
        final int currentTotalPoints = userAnswerDoc.exists
            ? (userAnswerDoc.data()?['total_points'] ?? 0)
            : 0;
        final int currentQuestionsAnswered = userAnswerDoc.exists
            ? (userAnswerDoc.data()?['questions_answered'] ?? 0)
            : 0;
        final int currentCorrectAnswers = userAnswerDoc.exists
            ? (userAnswerDoc.data()?['correct_answers'] ?? 0)
            : 0;

        // Create updated data map
        final Map<String, dynamic> updatedData = {
          'answers.${currentQuestion.value!.id}': {
            'selected_option': optionId,
            'is_correct': result.isCorrect,
            'points': result.points,
            'time_taken': currentQuestion.value!.time - timeLeft.value,
            'answered_at': FieldValue.serverTimestamp(),
          },
          'total_points': currentTotalPoints + result.points,
          'questions_answered': currentQuestionsAnswered + 1,
          'correct_answers': currentCorrectAnswers + (result.isCorrect ? 1 : 0),
          'updated_at': FieldValue.serverTimestamp(),
        };

        // Update the document
        transaction.update(userAnswerRef, updatedData);
      });

      print("Answer saved successfully using transaction");
    } catch (e) {
      print("Error in _saveUserAnswer transaction: $e");
    }
  }

  // Updates the contest leaderboard with the user's score
  Future<void> _updateLeaderboard(String contestId, String userId,
      String userDisplayName, int points) async {
    print("Starting comprehensive leaderboard update...");

    try {
      // Use transaction to safely update the leaderboard with all participant data
      await _firestore.runTransaction((transaction) async {
        // Get all answers for this contest
        final QuerySnapshot answersSnapshot = await _firestore
            .collection('contest_answers')
            .where('contest_id', isEqualTo: contestId)
            .get();

        print("Found ${answersSnapshot.docs.length} participant answers");
        // answeredParticipantsCount.value = answersSnapshot.docs.length;

        // Create leaderboard entries for all participants
        List<Map<String, dynamic>> leaderboardEntries = [];

        for (var doc in answersSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final participantId = data['user_id'] as String;
          final totalPoints = data['total_points'] as int;

          leaderboardEntries.add({
            'user_id': participantId,
            'points': totalPoints,
            'timestamp': DateTime.now().toUtc(),
            'user_display_name': userDisplayName
          });

          print(
              "Added user $participantId with $totalPoints points to leaderboard");
        }

        // Get the contest document reference
        final contestDocRef = _firestore.collection('contests').doc(contestId);
        final contestDoc = await transaction.get(contestDocRef);

        // Update the contest document with the new leaderboard within the transaction
        transaction.update(contestDocRef, {
          'leaderboard': leaderboardEntries,
        });
      });

      print("Comprehensive leaderboard update completed");
    } catch (e) {
      print("Error updating comprehensive leaderboard: $e");
    }
  }
  // Future<void> _updateLeaderboard(
  //     String contestId, String userId, int points) async {
  //   print("Starting leaderboard update...");

  //   // Create new entry for the leaderboard
  //   final newEntry = {
  //     'user_id': userId,
  //     'points': points,
  //     'timestamp': DateTime.now().toUtc(),
  //   };

  //   // Use transaction to safely update the leaderboard
  //   print('Updating Firestore with new leaderboard entry...');
  //   await _firestore.runTransaction((transaction) async {
  //     final doc = await transaction
  //         .get(_firestore.collection('contests').doc(contestId));

  //     final currentLeaderboard =
  //         List<Map<String, dynamic>>.from(doc['leaderboard'] ?? []);

  //     final filtered =
  //         currentLeaderboard.where((e) => e['user_id'] != userId).toList();

  //     transaction.update(doc.reference, {
  //       'leaderboard': [...filtered, newEntry]
  //     });
  //   });

  //   print("Leaderboard update completed");
  // }

  // Add this near other observable variables
  final isQuizCompleted = false.obs;

  Future<void> moveToNextQuestion() async {
    try {
      print('Starting moveToNextQuestion...');
      final contestId = _questionsController.currentContestId.value;
      print('Contest ID: $contestId');
      if (contestId.isEmpty) return;

      print('Fetching contest document...');
      final contestDoc =
          await _firestore.collection('contests').doc(contestId).get();
      final List<dynamic> questionsData = contestDoc.data()?['questions'] ?? [];
      print('Questions data length: ${questionsData.length}');
      final questions = questionsData.map((q) => Question.fromJson(q)).toList();
      print('Parsed questions length: ${questions.length}');

      final int nextIndex = currentQuestionIndex.value + 1;
      print('Next question index: $nextIndex');
      if (nextIndex < questions.length) {
        print('Moving to next question...');
        final nextQuestion = questions[nextIndex];
        print('Next question ID: ${nextQuestion.id}');
        final Timestamp now = Timestamp.now();

        print('Updating Firestore with next question data...');
        await _firestore.collection('contests').doc(contestId).update({
          'current_question.id': nextQuestion.id,
          'current_question.start_time': now,
          'current_question.end_time': Timestamp.fromDate(
              now.toDate().add(Duration(seconds: nextQuestion.time))),
          'current_question.status': 'active',
          'quiz_status.questions_completed': FieldValue.increment(1),
        });
        print('Firestore update completed');

        // Reset selection state
        selectedOption.value = null;
        hasAnswered.value = false;
        print('Selection state reset');
      } else {
        print('No more questions, completing quiz...');
        await _firestore.collection('contests').doc(contestId).update({
          'quiz_status.current_state': 'completed',
        });
        print('Quiz marked as completed in Firestore');
        _timer?.cancel();

        // Set quiz completed flag instead of direct navigation
        isQuizCompleted.value = true;
        print('Quiz completion flag set to true');
      }
    } catch (e) {
      print('Error moving to next question: $e');
    }
  }

  void resetAttemptTime() {
    timeLeft.value = eachQuestionTimeInSeconds;
  }

  String formatTime(int seconds) {
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>?> getUserAnswers(String userId) async {
    try {
      final contestId = _questionsController.currentContestId.value;
      if (contestId.isEmpty) return null;

      final docSnapshot = await _firestore
          .collection('contest_answers')
          .doc('${contestId}_$userId')
          .get();

      return docSnapshot.data();
    } catch (e) {
      print('Error fetching user answers: $e');
      return null;
    }
  }

  void cancelOperations() {
    _timer?.cancel();
    _contestSubscription?.cancel();
  }

  void resetQuizState() {
    currentQuestion.value = null;
    currentQuestionIndex.value = 0;
    timeLeft.value = 120;
    selectedOption.value = null;
    hasAnswered.value = false;
    leaderboard.clear();
    topLeaderboard.clear();
    showLeaderboard.value = false;
    isQuizCompleted.value = false;
    _timer?.cancel();
    _contestSubscription?.cancel();
  }
}
