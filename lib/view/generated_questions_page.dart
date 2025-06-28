import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzler/controller/generate_questions_controller.dart';
import 'package:quizzler/utils/constants.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';
import 'package:quizzler/view/questions_screen.dart';
import 'package:quizzler/view/widgets/coin_display_widget.dart';
import 'package:quizzler/view/widgets/rotation_animation.dart';

class GeneratedQuestionsPage extends StatelessWidget {
  final bool showBackButton;

  const GeneratedQuestionsPage({
    Key? key,
    this.showBackButton = false,
  }) : super(key: key);

  // Method to show the coin cost confirmation dialog
  Future<bool?> _showCoinCostDialog(BuildContext context, int cost) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Start Quiz',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: context.primaryColor,
            ),
          ),
          content: Text(
            'This will cost $cost coins to start the quiz. Do you want to proceed?',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Proceed',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final GenerateQuestionsController controller =
        Get.find<GenerateQuestionsController>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: context.primaryColor),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Generated Questions',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: context.primaryColor,
              ),
            ),
            CoinDisplayWidget(), // Display remaining coins
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child:
                GetX<GenerateQuestionsController>(builder: (widgetController) {
              if (widgetController.isLoading.isTrue) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: RotationAnimation(),
                      ),
                      SizedBox(
                        height: SizeConstants.defaultPadding * 2,
                      ),
                      Text(
                        "Generating Questions",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: context.primaryColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Please wait while we create your quiz...",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: SizeConstants.defaultPadding * 4),
                    ],
                  ),
                );
              }

              return QuestionScreen(withExtraPadding: true);
            }),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConstants.defaultPadding,
                vertical: SizeConstants.defaultPadding / 2,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(0),
                    Colors.white.withAlpha(179),
                  ],
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final controller = Get.find<GenerateQuestionsController>();
                  final cost = controller.calculateCoinCost();

                  // Show the coin cost confirmation dialog
                  // final confirmed = await _showCoinCostDialog(context, cost);
                  // if (confirmed != true) {
                  //   return; // User canceled
                  // }

                  // // Deduct coins after confirmation
                  // final success = await controller.deductCoinsForQuiz(context, _questions);
                  // if (!success) {
                  //   return; // Coin deduction failed (error message already shown)
                  // }

                  // Proceed to start the quiz
                  await controller.startQuizNow(context: context);
                },
                icon: Icon(Icons.play_arrow_rounded),
                label: Text(
                  "Start Quiz",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  elevation: 8,
                  shadowColor: context.primaryColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  minimumSize: Size(double.infinity, 56),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
