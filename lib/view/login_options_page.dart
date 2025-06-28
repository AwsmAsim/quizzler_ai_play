import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizzler/controller/generate_questions_controller.dart';
import 'package:quizzler/utils/constants.dart';
import 'package:quizzler/utils/smooth_navigator.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';
import 'package:quizzler/view/home_page.dart';
import 'package:quizzler/view/question_generator_form.dart';
import 'package:quizzler/controller/auth_controller.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'login_page.dart';
import 'settings_screen.dart';

class LoginOptionsPage extends StatelessWidget {
  // Get auth controller
  final AuthController _authController = Get.find<AuthController>();
  final quizCodeController = TextEditingController();

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: _responsivePadding(context), // Scaled padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),

                    Column(
                      children: [
                        // App Icon
                        Image.asset(
                          'assets/images/qizzler-play-logo-no-play-icon.png',
                          width: _scaleSize(context, 100), // Scaled logo size
                          height: _scaleSize(context, 100),
                        ),
                        SizedBox(height: _scaleSize(context, 32)),

                        // Welcome Text
                        Text(
                          'Welcome to Quizzler',
                          style: GoogleFonts.poppins(
                            fontSize: _scaleSize(context, 24),
                            color: context.primaryColor,
                          ),
                        ),
                        SizedBox(height: _scaleSize(context, 8)),
                        Text(
                          'Create or join a quiz game',
                          style: GoogleFonts.poppins(
                            fontSize: _scaleSize(context, 14),
                            color: context.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: _scaleSize(context, 32)),
                    // Quiz code entering
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: _scaleSize(
                                context, 60), // Scaled text field height
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(_scaleSize(context, 100)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: _scaleSize(context, 2),
                                blurRadius: _scaleSize(context, 5),
                                offset: Offset(0, _scaleSize(context, 3)),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: _scaleSize(context, 16),
                              vertical: _scaleSize(
                                  context, 12), // Vertical padding for height
                            ),
                            child: TextField(
                              controller: quizCodeController,
                              style: TextStyle(
                                fontSize: _scaleSize(context, 16),
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter Quiz Code...',
                                hintStyle: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: _scaleSize(context, 16),
                                  color: context.primaryColor,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                            height: _scaleSize(
                                context, SizeConstants.defaultPadding)),

                        // Start Quiz
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _handleJoinQuiz(context);
                            },
                            label: Text(
                              "Start Quiz",
                              style: GoogleFonts.poppins(
                                fontSize: _scaleSize(context, 16),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: context.backgroundColor,
                              padding: EdgeInsets.symmetric(
                                vertical: _scaleSize(context, 16),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    _scaleSize(context, 100)),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                            height: _scaleSize(
                                context, SizeConstants.defaultPadding)),

                        // Create your own Quiz text
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(_scaleSize(context, 100)),
                          child: Material(
                            child: InkWell(
                              onTap: () {
                                _handleCreateQuiz(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: _scaleSize(
                                      context, SizeConstants.defaultPadding),
                                ),
                                child: Center(
                                  child: Text(
                                    'Create your own quiz >',
                                    style: TextStyle(
                                      fontFamily: 'poppins',
                                      color: context.primaryColor,
                                      fontSize: _scaleSize(context, 14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Settings Icon in Top-Right Corner
          Positioned(
            top: _scaleSize(context, 40), // Scaled position
            right: _scaleSize(context, 24),
            child: IconButton(
              icon: Icon(
                Icons.settings,
                color: context.primaryColor,
                size: _scaleSize(context, 28),
              ),
              onPressed: () {
                SmoothNavigator.push(context, SettingsScreen());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context,
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: _scaleSize(context, 20),
          color: context.thirdColor,
        ),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: _scaleSize(context, 16),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.backgroundColor,
          foregroundColor: context.primaryColor,
          padding: EdgeInsets.symmetric(
            vertical: _scaleSize(context, 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_scaleSize(context, 100)),
          ),
        ),
      ),
    );
  }

  // Method to handle quiz creation with auth check
  void _handleCreateQuiz(BuildContext context) async {
    if (_authController.isLoggedIn.value) {
      if (_authController.currentUser.value?.displayName == null) {
        _showDisplayNameDialog(context);
      } else {
        SmoothNavigator.push(context, QuestionGeneratorForm());
      }
    } else {
      _showLoginBottomSheet(context);
    }
  }

  // Show minimal login bottom sheet
  void _showLoginBottomSheet(BuildContext context,
      {VoidCallback? afterLogin,
      String loginTitle = 'Login Required',
      bool isJoiningQuiz = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_scaleSize(context, 20)),
            topRight: Radius.circular(_scaleSize(context, 20)),
          ),
        ),
        padding: EdgeInsets.all(_scaleSize(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loginTitle,
              style: GoogleFonts.poppins(
                fontSize: _scaleSize(context, 20),
                fontWeight: FontWeight.w600,
                color: context.primaryColor,
              ),
            ),
            SizedBox(height: _scaleSize(context, 8)),
            Text(
              'Please login to continue',
              style: GoogleFonts.poppins(
                fontSize: _scaleSize(context, 14),
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: _scaleSize(context, 24)),

            // Google Sign In Button
            _buildSocialLoginButton(
              context,
              label: 'Continue with Google',
              icon: 'assets/images/google_logo.webp',
              onPressed: () async {
                Navigator.pop(context);
                await _authController.signInWithGoogle(context);
                if (_authController.isLoggedIn.value && afterLogin == null) {
                  SmoothNavigator.push(context, QuestionGeneratorForm());
                } else if (_authController.isLoggedIn.value &&
                    afterLogin != null) {
                  afterLogin();
                }
              },
            ),

            SizedBox(height: _scaleSize(context, 16)),

            // Apple Sign In Button (only on iOS)
            if (defaultTargetPlatform == TargetPlatform.iOS)
              _buildSocialLoginButton(
                context,
                label: 'Continue with Apple',
                icon: 'assets/images/apple_logo.png',
                onPressed: () async {
                  Navigator.pop(context);
                  await _authController.signInWithApple(context);
                  if (_authController.isLoggedIn.value && afterLogin == null) {
                    SmoothNavigator.push(context, QuestionGeneratorForm());
                  } else if (_authController.isLoggedIn.value &&
                      afterLogin != null) {
                    afterLogin();
                  }
                },
              ),

            if (defaultTargetPlatform == TargetPlatform.iOS)
              SizedBox(height: _scaleSize(context, 16)),

            // Email Sign In Button
            _buildSocialLoginButton(
              context,
              label: 'Continue with Email',
              icon: 'assets/images/email_logo.png',
              onPressed: () {
                Navigator.pop(context);
                SmoothNavigator.push(context, LoginPage());
              },
            ),

            SizedBox(height: _scaleSize(context, 16)),

            // Anonymous Sign In Button (Guest login) - only show when joining a quiz
            if (isJoiningQuiz)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _authController.signInAnonymously(context);
                    if (_authController.isLoggedIn.value &&
                        afterLogin == null) {
                      SmoothNavigator.push(context, QuestionGeneratorForm());
                    } else if (_authController.isLoggedIn.value &&
                        afterLogin != null) {
                      afterLogin();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: context.primaryColor,
                    padding: EdgeInsets.symmetric(
                      vertical: _scaleSize(context, 12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(_scaleSize(context, 8)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: _scaleSize(context, 24),
                        color: context.primaryColor,
                      ),
                      SizedBox(width: _scaleSize(context, 12)),
                      Text(
                        'Continue as Guest',
                        style: GoogleFonts.poppins(
                          fontSize: _scaleSize(context, 14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: _scaleSize(context, 24)),
          ],
        ),
      ),
    );
  }

  // Build social login button
  Widget _buildSocialLoginButton(
    BuildContext context, {
    required String label,
    required String icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: EdgeInsets.symmetric(
            vertical: _scaleSize(context, 12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_scaleSize(context, 8)),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: _scaleSize(context, 24),
              height: _scaleSize(context, 24),
            ),
            SizedBox(width: _scaleSize(context, 12)),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: _scaleSize(context, 14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleJoinQuiz(BuildContext context) {
    GenerateQuestionsController quizController = Get.find();
    final code = quizCodeController.text.trim();

    // Check if code is empty
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a quiz code')),
      );
      return;
    }

    // Check if user is logged in
    if (!_authController.isLoggedIn.value) {
      _showLoginBottomSheet(context,
          afterLogin: () => _handleJoinQuiz(context),
          loginTitle: 'Join Quiz',
          isJoiningQuiz: true);
      return;
    }

    quizController.joinQuizWithCode(
      context: context,
      code: code,
    );
  }

  // Show dialog to get display name
  void _showDisplayNameDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_scaleSize(context, 16)),
          ),
          title: Text(
            'Enter Your Name',
            style: GoogleFonts.poppins(
              fontSize: _scaleSize(context, 20),
              color: context.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please enter your display name to continue',
                style: GoogleFonts.poppins(
                  fontSize: _scaleSize(context, 14),
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: _scaleSize(context, 16)),
              Container(
                constraints: BoxConstraints(
                  minHeight:
                      _scaleSize(context, 50), // Scaled text field height
                ),
                child: TextField(
                  controller: nameController,
                  style: TextStyle(
                    fontSize: _scaleSize(context, 16),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Your name',
                    hintStyle: TextStyle(
                      fontSize: _scaleSize(context, 14),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(_scaleSize(context, 8)),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  autofocus: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _authController.isUpdatingDisplayName.value
                  ? null
                  : () async {
                      debugPrint('Display name dialog continue button pressed');
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter your name')),
                        );
                        return;
                      }

                      try {
                        _authController.isUpdatingDisplayName.value = true;
                        bool success = await _authController
                            .updateUserDisplayName(context, name);

                        if (success && context.mounted) {
                          Navigator.of(context).pop();
                          SmoothNavigator.push(
                              context, QuestionGeneratorForm());
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to update display name')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      } finally {
                        _authController.isUpdatingDisplayName.value = false;
                      }
                    },
              child: Obx(
                () => _authController.isUpdatingDisplayName.value
                    ? SizedBox(
                        height: _scaleSize(context, 24),
                        width: _scaleSize(context, 24),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'CONTINUE',
                        style: GoogleFonts.poppins(
                          fontSize: _scaleSize(context, 14),
                          color: context.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
