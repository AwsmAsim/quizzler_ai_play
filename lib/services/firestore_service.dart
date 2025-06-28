import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save quiz questions
  Future<void> saveQuizQuestions(String userId, Map<String, dynamic> quizData) async {
    try {
      await _firestore.collection('quizzes').doc(userId).collection('saved_quizzes').add({
        'quizData': quizData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get user's saved quizzes
  Stream<QuerySnapshot> getUserQuizzes(String userId) {
    return _firestore
        .collection('quizzes')
        .doc(userId)
        .collection('saved_quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Save user quiz results
  Future<void> saveQuizResults(String userId, Map<String, dynamic> results) async {
    try {
      await _firestore.collection('users').doc(userId).collection('quiz_results').add({
        'results': results,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}