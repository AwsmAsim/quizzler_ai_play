import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzler/controller/generate_questions_controller.dart';
import 'package:quizzler/utils/constants.dart';
import 'package:quizzler/utils/smooth_navigator.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';
import 'package:quizzler/view/waiting_screen.dart';

class QuizParticipationMode extends StatelessWidget {
  const QuizParticipationMode({Key? key}) : super(key: key);

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
    ValueNotifier<bool>? isProcessing,
  }) {
    Widget cardContent = Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(
                    enabled && (isProcessing?.value ?? true) ? 0.1 : 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: context.primaryColor.withOpacity(
                    enabled && (isProcessing?.value ?? true) ? 1.0 : 0.5),
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'poppins',
                      color: context.primaryColor.withOpacity(
                          enabled && (isProcessing?.value ?? true) ? 1.0 : 0.5),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600]!.withOpacity(
                          enabled && (isProcessing?.value ?? true) ? 1.0 : 0.7),
                      fontFamily: 'poppins',
                    ),
                  ),
                ],
              ),
            ),
            enabled && (isProcessing?.value ?? true)
                ? Icon(
                    Icons.arrow_forward_ios,
                    color: context.primaryColor,
                    size: 16,
                  )
                : enabled
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              context.primaryColor),
                        ),
                      )
                    : Text(
                        'Coming Soon',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.primaryColor.withOpacity(0.7),
                          fontFamily: 'poppins',
                        ),
                      ),
          ],
        ),
      ),
    );

    return enabled
        ? ValueListenableBuilder<bool>(
            valueListenable: isProcessing ?? ValueNotifier(true),
            builder: (context, isEnabled, child) {
              return GestureDetector(
                onTap: isEnabled ? onTap : null,
                child: cardContent,
              );
            },
          )
        : cardContent;
  }

  @override
  Widget build(BuildContext context) {
    final GenerateQuestionsController controller =
        Get.find<GenerateQuestionsController>();
    final ValueNotifier<bool> isProcessing = ValueNotifier(true);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choose Participation Mode',
          style: TextStyle(
            color: context.primaryColor,
            fontSize: 24,
            fontFamily: 'poppins',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'How would you like to participate?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'poppins',
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildOptionCard(
                    context,
                    title: 'Self Participate',
                    description:
                        'Join as a participant and compete with others',
                    icon: Icons.play_arrow,
                    isProcessing: isProcessing,
                    onTap: () async {
                      isProcessing.value = false;
                      print("updating quiz tim");
                      await controller.setParticipationMode(true);
                      await controller.updateQuizStartTime();
                      isProcessing.value = true;
                      print("Navigating to WaitingScreen");
                      SmoothNavigator.push(context, WaitingScreen());
                    },
                  ),
                  _buildOptionCard(
                    context,
                    title: 'Spectator Mode',
                    description:
                        'Review and edit questions before the quiz starts',
                    icon: Icons.remove_red_eye_outlined,
                    onTap: () {},
                    enabled: false,
                  ),
                  _buildOptionCard(
                    context,
                    title: 'Solo Quiz',
                    description: 'Take the quiz by yourself',
                    icon: Icons.person_outlined,
                    onTap: () {},
                    enabled: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
