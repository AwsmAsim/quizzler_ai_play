import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quizzler/controller/coin_controller.dart';
import 'package:quizzler/model/user_model.dart';
import 'package:quizzler/view/widgets/custom_alert_dialog.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final isUpdatingDisplayName = false.obs;
  CoinController coinController = Get.find();

  var isLoggedIn = false.obs;
  var currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      print("Auth state changed: $user");
      print(currentUser.value?.email);
      currentUser.value = user;
      isLoggedIn.value = user != null;
    });
  }

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(
      BuildContext context, String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await coinController.initializeCoins();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      dev.log('Error signing in with email/password: $e');

      String errorMessage = 'Failed to sign in';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        default:
          errorMessage = 'Sign-in error: ${e.message}';
      }

      CustomAlertDialog.show(
        context: context,
        title: 'Sign-In Failed',
        message: errorMessage,
        primaryButtonText: 'OK',
      );

      return null;
    } catch (e) {
      dev.log('Unexpected error during sign-in: $e');

      CustomAlertDialog.show(
        context: context,
        title: 'Sign-In Failed',
        message: 'An unexpected error occurred. Please try again.',
        primaryButtonText: 'OK',
      );

      return null;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailPassword(
      BuildContext context, String email, String password, String name) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        dev.log('Invalid email format');
        CustomAlertDialog.show(
          context: context,
          title: 'Invalid Email',
          message: 'Please enter a valid email address.',
          primaryButtonText: 'OK',
        );
        return null;
      }

      if (password.length < 6) {
        dev.log('Password must be at least 6 characters');
        CustomAlertDialog.show(
          context: context,
          title: 'Weak Password',
          message: 'Password must be at least 6 characters long.',
          primaryButtonText: 'OK',
        );
        return null;
      }

      dev.log("Creating user with email: $email");
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      dev.log("User created successfully: ${userCredential.user?.uid}");
      dev.log("Updating user display name to: $name");

      await userCredential.user?.updateDisplayName(name);
      dev.log("User display name updated successfully");

      if (userCredential.user != null) {
        await _createUserDetailsDocument(userCredential.user!, name, email);
        CoinController coinController = Get.find();
        await coinController.initializeCoins();
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        default:
          errorMessage = 'Registration error: ${e.message}';
      }

      dev.log(errorMessage);
      dev.log('Firebase Auth Exception details: ${e.message}');

      CustomAlertDialog.show(
        context: context,
        title: 'Registration Failed',
        message: errorMessage,
        primaryButtonText: 'OK',
      );

      return null;
    } catch (e) {
      dev.log('Unexpected error during registration: $e');
      CustomAlertDialog.show(
        context: context,
        title: 'Registration Failed',
        message: 'An unexpected error occurred. Please try again.',
        primaryButtonText: 'OK',
      );
      return null;
    }
  }

  // Create user details document using UserModel
  Future<void> _createUserDetailsDocument(
      User user, String name, String email) async {
    try {
      final userModel = UserModel(
        userId: user.uid,
        email: email,
        displayName: name,
        joinDate: null, // Will be set by Firestore
        dateOfBirth: null,
        profilePictureUrl: null,
        phoneNumber: null,
        address: null,
        bio: null,
        coins: 100,
        dailyCoinsLastClaimed: null, // Will be set by Firestore
      );

      // Use FieldValue.serverTimestamp() directly in the Firestore document
      await _firestore.collection('user_details').doc(user.uid).set({
        'user_personal_details': {
          ...userModel.toMap(),
          'join_date': FieldValue.serverTimestamp(),
          'daily_coins_last_claimed': FieldValue.serverTimestamp(),
        },
      });
      dev.log(
          "User details document created successfully for UID: ${user.uid}");
    } catch (e) {
      dev.log("Error creating user details document: $e");
      throw Exception("Failed to create user details in Firestore: $e");
    }
  }

  // Update signInWithGoogle method
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _ensureUserDetailsExist(
          userCredential.user!,
          userCredential.user!.displayName ?? 'Google User',
          userCredential.user!.email ?? '',
        );
        await coinController.initializeCoins();
      }

      return userCredential.user;
    } catch (e) {
      dev.log('Error signing in with Google: $e');
      CustomAlertDialog.show(
        context: context,
        title: 'Google Sign-In Failed',
        message: 'There was an error signing in with Google. Please try again.',
        primaryButtonText: 'OK',
      );
      return null;
    }
  }

  // Update signInWithApple method
  Future<User?> signInWithApple(BuildContext context) async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);

      String displayName = 'Apple User';
      if (userCredential.user != null &&
          userCredential.user!.displayName == null &&
          appleCredential.givenName != null) {
        displayName =
            "${appleCredential.givenName} ${appleCredential.familyName}";
        await userCredential.user!.updateDisplayName(displayName);
      } else if (userCredential.user?.displayName != null) {
        displayName = userCredential.user!.displayName!;
      }

      if (userCredential.user != null) {
        await _ensureUserDetailsExist(
          userCredential.user!,
          displayName,
          userCredential.user!.email ?? '',
        );
        await coinController.initializeCoins();
      }

      return userCredential.user;
    } catch (e) {
      dev.log('Error signing in with Apple: $e');
      CustomAlertDialog.show(
        context: context,
        title: 'Apple Sign-In Failed',
        message: 'There was an error signing in with Apple. Please try again.',
        primaryButtonText: 'OK',
      );
      return null;
    }
  }

  // Update signInAnonymously method
  Future<User?> signInAnonymously(BuildContext context) async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();

      if (userCredential.user != null) {
        await _ensureUserDetailsExist(
          userCredential.user!,
          'Guest User',
          '',
        );
      }

      return userCredential.user;
    } catch (e) {
      dev.log('Error signing in anonymously: $e');
      CustomAlertDialog.show(
        context: context,
        title: 'Anonymous Sign-In Failed',
        message: 'There was an error signing in anonymously. Please try again.',
        primaryButtonText: 'OK',
      );
      return null;
    }
  }

  // Ensure user details exist and update using UserModel
  Future<void> _ensureUserDetailsExist(
      User user, String name, String email) async {
    try {
      final docSnapshot =
          await _firestore.collection('user_details').doc(user.uid).get();

      if (!docSnapshot.exists) {
        await _createUserDetailsDocument(user, name, email);
      } else {
        final userData = docSnapshot.data();
        if (userData != null && userData['user_personal_details'] != null) {
          final userModel =
              UserModel.fromMap(userData['user_personal_details']);
          userModel.displayName = name; // Update display name
          await _firestore.collection('user_details').doc(user.uid).update({
            'user_personal_details': userModel.toMap(),
          });
        }
      }
    } catch (e) {
      dev.log("Error ensuring user details exist: $e");
    }
  }

  // Update user display name
  Future<bool> updateUserDisplayName(BuildContext context, String name) async {
    try {
      if (currentUser.value == null) {
        return false;
      }

      await currentUser.value!.updateDisplayName(name);
      await _ensureUserDetailsExist(
        currentUser.value!,
        name,
        currentUser.value!.email ?? '',
      );

      return true;
    } catch (e) {
      dev.log('Error updating display name: $e');
      CustomAlertDialog.show(
        context: context,
        title: 'Update Failed',
        message:
            'There was an error updating your display name. Please try again.',
        primaryButtonText: 'OK',
      );
      return false;
    }
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      dev.log('Error signing out: $e');
      CustomAlertDialog.show(
        context: context,
        title: 'Sign-Out Failed',
        message: 'There was an error signing out. Please try again.',
        primaryButtonText: 'OK',
      );
    }
  }

  // Generate a random nonce for Apple Sign In
  String _generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  // SHA256 hash for nonce
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
