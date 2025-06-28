import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizzler/main.dart';
import 'package:quizzler/utils/constants.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';
import 'package:quizzler/view/question_generator_form.dart';
import 'package:quizzler/view/widgets/analytics_quick_look_widgets.dart';

import '../controller/theme_controller.dart';

class HomePage extends StatelessWidget {

  // Sample quiz data
  final List<Map<String, dynamic>> quizzes = [
    {
      'title': 'Mathematics Basics',
      'time': '10:00 AM',
      'date': '2023-08-15',
      'duration': '30 mins'
    },
    {
      'title': 'Science Fundamentals',
      'time': '02:00 PM',
      'date': '2023-08-16',
      'duration': '45 mins'
    },
    {
      'title': 'History Trivia',
      'time': '11:30 AM',
      'date': '2023-08-17',
      'duration': '1 hour'
    },
    {
      'title': 'Geography Challenge',
      'time': '09:00 AM',
      'date': '2023-08-18',
      'duration': '45 mins'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: context.ctaColor,
        child: Center(
          child: Icon(Icons.add, color: Colors.white,),
        ),
          onPressed: (){
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 500),
                pageBuilder: (_, __, ___) => QuestionGeneratorForm(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          }
      ),
      backgroundColor: context.backgroundColor,
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConstants.defaultPadding),
            child: SizedBox(
              height: 50.0,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Hi, Mr Shams",
                    style: GoogleFonts.poppins(
                      color: context.primaryColor,
                      fontSize: 18.0
                    ),
                  ),
                  Text("Log out",
                    style: GoogleFonts.poppins(
                        color: context.wrongColor,
                        fontSize: 14.0
                    ),
                  ),
                  // IconButton(
                  //   icon: Icon(Icons.login,
                  //     color: context.primaryColor,
                  //   ),
                  //   onPressed: Get.find<ThemeController>().toggleTheme,
                  // )
                  // Container(
                  //   height: double.infinity,
                  //   width: 150,
                  //   decoration: BoxDecoration(
                  //     // border: Border.all(color: Colors.black),
                  //     image: DecorationImage(
                  //         image: AssetImage('assets/images/quizzler-icon-only-text.png')
                  //     )
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: SizeConstants.defaultPadding,
          ),

          Container(
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(left: SizeConstants.defaultPadding),
                  height: 25,
                  child: Text("Upcoming Quizzes",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: context.primaryColor
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(16),
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = quizzes[index];
                      return Container(
                        width: MediaQuery.of(context).size.width*0.7,
                        margin: EdgeInsets.only(right: SizeConstants.defaultPadding),
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quiz['title'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: context.primaryColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: context.thirdColor,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${quiz['date']} • ${quiz['time']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 16,
                                    color: context.thirdColor,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Duration: ${quiz['duration']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: context.ctaColor,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {
                                    // Handle join quiz
                                  },
                                  child: Text(
                                    'View',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: SizeConstants.defaultPadding,
          ),

          Container(
            height: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(left: SizeConstants.defaultPadding),
                  height: 25,
                  child: Text("Recent Analytics",
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: context.primaryColor
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(16),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.of(context).size.width - SizeConstants.defaultPadding*2,
                        margin: EdgeInsets.only(right: SizeConstants.defaultPadding),
                        decoration: BoxDecoration(
                          color: context.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(SizeConstants.defaultPadding),
                          child: AnalyticsQuickLookWidget(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
