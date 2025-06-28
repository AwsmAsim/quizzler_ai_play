import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzler/controller/auth_controller.dart';
import 'package:quizzler/model/user_model.dart';
import 'dart:developer' as dev;
import 'package:quizzler/utils/custom_snackbar.dart';

// CoinController to manage the coin system
class CoinController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reactive variables for coin balance and last claim date
  final RxInt coins = 0.obs;
  final Rx<DateTime?> lastClaimDate = Rx<DateTime?>(null);
  final RxInt dailyCoinLimit =
      100.obs; // Default limit, will be fetched from Firestore
  final RxBool showResetPopup = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch the daily coin limit from Firestore config
    _fetchDailyCoinLimit();
    // Initialize coins when the controller is created
    initializeCoins();
  }

  // Fetch the daily coin limit from a config collection
  Future<void> _fetchDailyCoinLimit() async {
    try {
      final configDoc =
          await _firestore.collection('config').doc('settings').get();
      if (configDoc.exists && configDoc.data()!['daily_coin_limit'] != null) {
        dailyCoinLimit.value = configDoc.data()!['daily_coin_limit'] as int;
      }
    } catch (e) {
      dev.log('Error fetching daily coin limit: $e');
      // Use default value if fetching fails
    }
  }

  // Initialize or reset coins based on the daily limit
  Future<void> initializeCoins() async {
    final user = _auth.currentUser;
    if (user == null) {
      dev.log('No user logged in, cannot initialize coins');
      return;
    }

    try {
      final doc =
          await _firestore.collection('user_details').doc(user.uid).get();
      if (!doc.exists || doc.data()!['user_personal_details'] == null) {
        dev.log('User details not found for UID: ${user.uid}');
        return;
      }

      final userModel = UserModel.fromMap(doc.data()!['user_personal_details']);
      final now = DateTime.now();
      final istOffset = Duration(hours: 5, minutes: 30); // IST is UTC+5:30
      final istNow = now.toUtc().add(istOffset);

      // Initialize coins and last claim date if they're null
      if (userModel.coins == null || userModel.dailyCoinsLastClaimed == null) {
        userModel.coins = dailyCoinLimit.value;
        userModel.dailyCoinsLastClaimed = now; // Use DateTime
        await _firestore.collection('user_details').doc(user.uid).update({
          'user_personal_details': userModel.toMap(),
        });
      }

      final lastClaimed = userModel.dailyCoinsLastClaimed!;
      final lastClaimedIst = lastClaimed.toUtc().add(istOffset);

      // Reset coins if last claim was before today in IST
      if (!_isSameDay(lastClaimedIst, istNow)) {
        userModel.coins = dailyCoinLimit.value;
        userModel.dailyCoinsLastClaimed = now; // Use DateTime
        await _firestore.collection('user_details').doc(user.uid).update({
          'user_personal_details': userModel.toMap(),
        });
        showResetPopup.value = true;
      }

      // Update reactive variables
      coins.value = userModel.coins ?? 0;
      lastClaimDate.value = userModel.dailyCoinsLastClaimed;
    } catch (e) {
      dev.log('Error initializing coins: $e');
    }
  }

  // Check if two dates are the same day in IST
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Deduct a coin using a transaction
  Future<bool> deductCoin(BuildContext context, int coinsToDeduct) async {
    final user = _auth.currentUser;
    if (user == null) {
      dev.log('No user logged in, cannot deduct coin');
      return false;
    }

    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        final docRef = _firestore.collection('user_details').doc(user.uid);
        final doc = await transaction.get(docRef);

        if (!doc.exists || doc.data()!['user_personal_details'] == null) {
          dev.log('User details not found for UID: ${user.uid}');
          return false;
        }

        final userModel =
            UserModel.fromMap(doc.data()!['user_personal_details']);
        if (userModel.coins == null || userModel.coins! <= 0) {
          return false;
        }

        userModel.coins = userModel.coins! - coinsToDeduct;
        transaction.update(docRef, {
          'user_personal_details': userModel.toMap(),
        });

        // Update reactive variable
        coins.value = userModel.coins!;
        return true;
      });
    } catch (e) {
      dev.log('Error deducting coin: $e');
      CustomSnackbar.showError(
        context: context,
        message: 'Error deducting coin. Please try again.',
      );
      return false;
    }
  }

  // Add coins (e.g., as a reward)
  Future<bool> addCoins(int amount, BuildContext context) async {
    if (amount <= 0) {
      dev.log('Cannot add zero or negative coins');
      return false;
    }

    final user = _auth.currentUser;
    if (user == null) {
      dev.log('No user logged in, cannot add coins');
      return false;
    }

    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        final docRef = _firestore.collection('user_details').doc(user.uid);
        final doc = await transaction.get(docRef);

        if (!doc.exists || doc.data()!['user_personal_details'] == null) {
          dev.log('User details not found for UID: ${user.uid}');
          return false;
        }

        final userModel =
            UserModel.fromMap(doc.data()!['user_personal_details']);
        userModel.coins = (userModel.coins ?? 0) + amount;

        transaction.update(docRef, {
          'user_personal_details': userModel.toMap(),
        });

        // Update reactive variable
        coins.value = userModel.coins!;
        return true;
      });
    } catch (e) {
      dev.log('Error adding coins: $e');
      CustomSnackbar.showError(
        context: context,
        message: 'Error adding coins. Please try again.',
      );
      return false;
    }
  }
}
