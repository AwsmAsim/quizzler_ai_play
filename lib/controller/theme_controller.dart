import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:quizzler/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  late SharedPreferences _prefs;

  Future<ThemeController> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadTheme();
    return this;
  }

  void _loadTheme() {
    final isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    themeMode.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final newMode = themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _prefs.setBool('isDarkMode', newMode == ThemeMode.dark);
    if(newMode == ThemeMode.light){
      ColorsConstants.primaryColor = Color(0xFF2A4B7C);
      ColorsConstants.thirdColor = Color(0xFFC5A46D);
      ColorsConstants.correctColor = Color(0xFF80C783);
      ColorsConstants.wrongColor = Color(0xFFFF8080);
      ColorsConstants.ctaColor = Color(0xFFC5A46D);
    } else {
      ColorsConstants.primaryColor = Color(0xFF4A6B9C);
      ColorsConstants.thirdColor = Color(0xFFD4B47D);
      ColorsConstants.correctColor = Color(0xFF80C783);
      ColorsConstants.wrongColor = Color(0xFFFF8080);
      ColorsConstants.ctaColor = Color(0xFFC5A46D);
    }
    themeMode.value = newMode;
  }
}