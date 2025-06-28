import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quizzler/controller/auth_controller.dart';
import 'package:quizzler/controller/coin_controller.dart';
import 'package:quizzler/controller/contest_quiz_controller.dart';
import 'package:quizzler/services/firebase_service.dart';
import 'package:get/get.dart';
import 'package:quizzler/controller/generate_questions_controller.dart';
import 'package:quizzler/service/generate_question_service.dart';
import 'package:quizzler/utils/theme/themes.dart';
import 'package:quizzler/view/login_options_page.dart';
import 'controller/theme_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await FirebaseService.initializeFirebase();
  await Get.putAsync(() => ThemeController().init());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key) {
    Get.put(CoinController());
    Get.put(AuthController()); // Initialize AuthController
    Get.put(GenerateQuestionsController());
    Get.put(ContestQuizController()); // Initialize GenerateQuestionsController
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: () => SystemChannels.textInput.invokeMethod('TextInput.hide'),
          child: MaterialApp(
            theme: Themes.light,
            darkTheme: Themes.dark,
            themeMode: Get.find<ThemeController>().themeMode.value,
            debugShowCheckedModeBanner: false,
            home: Container(
              color:
                  Get.find<ThemeController>().themeMode.value == ThemeMode.light
                      ? Colors.white
                      : Color(0xFF121212),
              child: SafeArea(child: LoginOptionsPage()),
            ),
          ),
        ));
  }
}

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Theme Demo'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.brightness_6),
//             onPressed: Get.find<ThemeController>().toggleTheme,
//           )
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Primary Color', style: TextStyle(color: context.primaryColor)),
//             Text('CTA Color', style: TextStyle(color: context.ctaColor)),
//           ],
//         ),
//       ),
//     );
//   }
// }
