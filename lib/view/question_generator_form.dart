import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizzler/controller/auth_controller.dart';
import 'package:quizzler/controller/coin_controller.dart';
import 'package:quizzler/controller/generate_questions_controller.dart';
import 'package:quizzler/utils/constants.dart';
import 'package:quizzler/utils/smooth_navigator.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';
import 'package:quizzler/view/generated_questions_page.dart';
import 'package:get/get.dart';
import 'package:quizzler/view/quiz_participation_mode.dart';
import 'package:quizzler/view/widgets/custom_alert_dialog.dart';
import 'package:quizzler/view/widgets/rotation_animation.dart';

class QuestionGeneratorForm extends StatefulWidget {
  const QuestionGeneratorForm({Key? key}) : super(key: key);

  @override
  _QuestionGeneratorFormState createState() => _QuestionGeneratorFormState();
}

class _QuestionGeneratorFormState extends State<QuestionGeneratorForm> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final _topicController = TextEditingController();
  final _keywordsController = TextEditingController();

  // Form field values
  String? _selectedAgeGroup;
  String? _selectedDifficulty;
  String? _selectedLanguage;
  String? _selectedTimeLimit;
  String? _selectedNoOfQuestions;

  // Dropdown options
  final List<String> ageGroups = [
    'Children (5-12)',
    'Teenagers (13-19)',
    'Young Adults (20-30)',
    'Adults (31+)'
  ];
  final List<String> difficultyLevels = ['Easy', 'Medium', 'Hard', 'Expert'];
  final List<String> languages = ['English', 'Arabic'];
  final List<String> timeLimits = [
    '30 seconds',
    '45 seconds',
    '60 seconds',
    '120 seconds'
  ];
  final List<String> noOfQuestionsOptions = [
    '5 questions (Short Contest)',
    '10 questions (Standard Contest)'
  ];

  // Fixed cost for generating questions
  final int estimatedCoinCost = 10;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = 'Medium';
    _selectedLanguage = 'English';
    _selectedTimeLimit = '120 seconds';
    _selectedNoOfQuestions = '10 questions (Standard Contest)';
  }

  @override
  void dispose() {
    _topicController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

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

  // Method to show the coin cost confirmation dialog
  Future<bool?> _showCoinCostDialog(BuildContext context, int cost) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_scaleSize(context, 16)),
          ),
          title: Text(
            'Generate Questions',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: _scaleSize(context, 20),
              fontWeight: FontWeight.w600,
              color: context.primaryColor,
            ),
          ),
          content: Text(
            'This will cost $cost coins to generate questions. Do you want to proceed?',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: _scaleSize(context, 16),
              color: Colors.grey[800],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: _scaleSize(context, 16),
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_scaleSize(context, 8)),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: _scaleSize(context, 16),
                  vertical: _scaleSize(context, 8),
                ),
              ),
              child: Text(
                'Proceed',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: _scaleSize(context, 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget inputShadowWidget({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: _scaleSize(context, 16),
          ),
        ),
        SizedBox(height: _scaleSize(context, SizeConstants.defaultPadding / 2)),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight:
                _scaleSize(context, 50), // Scaled min height for text fields
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_scaleSize(context, 10)),
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
              horizontal: _scaleSize(context, SizeConstants.defaultPadding / 2),
              vertical: _scaleSize(
                  context, 1), // Increased vertical padding for taller fields
            ),
            child: child,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final CoinController coinController = Get.find<CoinController>();

    return Obx(() {
      if (coinController.showResetPopup.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          CustomAlertDialog.show(
            context: context,
            title: 'Daily Coins Reset!',
            message:
                'Congratulations! Your coins have been reset to ${coinController.dailyCoinLimit.value} for today.',
            primaryButtonText: 'OK',
            onPrimaryButtonPressed: () {
              coinController.showResetPopup.value = false;
            },
          );
        });
      }
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Question Generator',
            style: TextStyle(
              color: context.primaryColor,
              fontSize: _scaleSize(context, 24),
              fontFamily: 'poppins',
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(
                right: _scaleSize(context, 16),
                // top: _scaleSize(context, 8),
                // bottom: _scaleSize(context, 8),
              ),
              child: Obx(() => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(_scaleSize(context, 20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: _scaleSize(context, 1),
                          blurRadius: _scaleSize(context, 4),
                          offset: Offset(0, _scaleSize(context, 2)),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: _scaleSize(context, 12),
                      vertical: _scaleSize(context, 6),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/q_coin_logo.png',
                          height: _scaleSize(context, 20),
                          width: _scaleSize(context, 20),
                        ),
                        SizedBox(width: _scaleSize(context, 6)),
                        Text(
                          '${coinController.coins.value}',
                          style: TextStyle(
                            color: context.primaryColor,
                            fontSize: _scaleSize(context, 16),
                            fontFamily: 'poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: _responsivePadding(context),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      inputShadowWidget(
                        title: 'Describe Topic*',
                        child: TextFormField(
                          controller: _topicController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a topic description';
                            }
                            return null;
                          },
                          maxLines: 3,
                          style: TextStyle(
                            fontSize: _scaleSize(context, 16),
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Describe the Topic',
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
                      SizedBox(height: _scaleSize(context, 16)),
                      inputShadowWidget(
                        title: 'Audience Age Group*',
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Audience Age Group',
                            labelStyle: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: _scaleSize(context, 16),
                              color: context.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(
                                _scaleSize(context, 100),
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: _scaleSize(context, 16),
                            color: context.primaryColor,
                          ),
                          value: _selectedAgeGroup,
                          items: ageGroups.map((String group) {
                            return DropdownMenuItem(
                              value: group,
                              child: Text(
                                group,
                                style: TextStyle(
                                  fontSize: _scaleSize(context, 16),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedAgeGroup = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an age group';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: _scaleSize(context, 16)),
                      inputShadowWidget(
                        title: 'Keywords',
                        child: TextFormField(
                          controller: _keywordsController,
                          style: TextStyle(
                            fontSize: _scaleSize(context, 16),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Keywords',
                            labelStyle: TextStyle(
                              color: context.primaryColor,
                              fontFamily: 'poppins',
                              fontSize: _scaleSize(context, 16),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(
                                _scaleSize(context, 100),
                              ),
                            ),
                            hintText: 'Enter keywords separated by commas',
                            hintStyle: TextStyle(
                              fontSize: _scaleSize(context, 16),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: _scaleSize(
                              context, SizeConstants.defaultPadding)),
                      inputShadowWidget(
                        title: 'Difficulty Level',
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Difficulty Level',
                            labelStyle: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: _scaleSize(context, 16),
                              color: context.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(
                                _scaleSize(context, 100),
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: _scaleSize(context, 16),
                            color: context.primaryColor,
                          ),
                          value: _selectedDifficulty,
                          items: difficultyLevels.map((String level) {
                            return DropdownMenuItem(
                              value: level,
                              child: Text(
                                level,
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: _scaleSize(context, 16),
                                  color: context.primaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDifficulty = newValue;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: _scaleSize(context, 16)),
                      inputShadowWidget(
                        title: 'Language',
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Language',
                            labelStyle: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: _scaleSize(context, 16),
                              color: context.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(
                                _scaleSize(context, 100),
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: _scaleSize(context, 16),
                            color: context.primaryColor,
                          ),
                          value: _selectedLanguage,
                          items: languages.map((String language) {
                            return DropdownMenuItem(
                              value: language,
                              child: Text(
                                language,
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: _scaleSize(context, 16),
                                  color: context.primaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedLanguage = newValue;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: _scaleSize(context, 16)),
                      inputShadowWidget(
                        title: 'Time Limit on each question',
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Time Limit',
                            labelStyle: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: _scaleSize(context, 16),
                              color: context.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(
                                _scaleSize(context, 100),
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: _scaleSize(context, 16),
                            color: context.primaryColor,
                          ),
                          value: _selectedTimeLimit,
                          items: timeLimits.map((String time) {
                            return DropdownMenuItem(
                              value: time,
                              child: Text(
                                time,
                                style: TextStyle(
                                  fontSize: _scaleSize(context, 16),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedTimeLimit = newValue;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: _scaleSize(context, 16)),
                      inputShadowWidget(
                        title: 'Number of Questions',
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Number of Questions',
                            labelStyle: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: _scaleSize(context, 16),
                              color: context.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(
                                _scaleSize(context, 100),
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: _scaleSize(context, 16),
                            color: context.primaryColor,
                          ),
                          value: _selectedNoOfQuestions,
                          items: noOfQuestionsOptions.map((String option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: _scaleSize(context, 16),
                                  color: context.primaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedNoOfQuestions = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select the number of questions';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                          height: _scaleSize(
                              context, SizeConstants.defaultPadding)),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height:
                  _scaleSize(context, 100), // Scaled button container height
              padding: EdgeInsets.symmetric(
                vertical: _scaleSize(context, SizeConstants.defaultPadding),
                horizontal: _scaleSize(context, SizeConstants.defaultPadding),
              ),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  final confirmed = await _showCoinCostDialog(
                    context,
                    int.parse(_selectedNoOfQuestions!.split(' ')[0]),
                  );
                  if (confirmed != true) {
                    return;
                  }

                  final coinController = Get.find<CoinController>();
                  await coinController.initializeCoins();

                  if (coinController.coins.value < estimatedCoinCost) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Not enough coins to generate questions. You need $estimatedCoinCost coins.',
                        ),
                      ),
                    );
                    return;
                  }

                  AuthController authController = Get.find();
                  GenerateQuestionsController qController = Get.find();

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => PopScope(
                      canPop: false,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(_scaleSize(context, 16)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: _scaleSize(context, 10),
                                spreadRadius: _scaleSize(context, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(_scaleSize(context, 24)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RotationAnimation(),
                              SizedBox(height: _scaleSize(context, 16)),
                              Text(
                                'Generating Questions',
                                style: GoogleFonts.poppins(
                                  fontSize: _scaleSize(context, 16),
                                  color: context.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  try {
                    await qController.fetchQuestions(
                      context,
                      topic: _topicController.text,
                      ageGroup: _selectedAgeGroup ?? "any",
                      keywords: _keywordsController.text,
                      difficultyLevel: _selectedDifficulty ?? "Medium",
                      language: _selectedLanguage ?? "English",
                      timeLimit: _selectedTimeLimit != null
                          ? int.parse(_selectedTimeLimit!.split(' ')[0])
                          : 120,
                      noOfQuestions: _selectedNoOfQuestions != null
                          ? int.parse(_selectedNoOfQuestions!.split(' ')[0])
                          : 10,
                    );

                    final actualCost = qController.calculateCoinCost();
                    if (actualCost > 0) {
                      if (!await coinController.deductCoin(
                          context, actualCost)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Error deducting coins. Please try again.',
                            ),
                          ),
                        );
                        return;
                      }
                    }

                    if (context.mounted) Navigator.of(context).pop();
                    SmoothNavigator.push(context, QuizParticipationMode());
                  } catch (e) {
                    if (context.mounted) Navigator.of(context).pop();

                    // Format the error message to be more user-friendly
                    String errorMessage = e.toString();
                    if (e is Exception) {
                      errorMessage = e.toString().replaceAll('Exception: ', '');
                    } else {
                      errorMessage = 'An unexpected error occurred.';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to generate questions: $errorMessage',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                label: Text(
                  "Create Quiz",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: _scaleSize(context, 16),
                    color: context.backgroundColor,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: context.backgroundColor,
                  padding: EdgeInsets.symmetric(
                    vertical: _scaleSize(context, 16),
                    horizontal: _scaleSize(context, 24),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(_scaleSize(context, 100)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
