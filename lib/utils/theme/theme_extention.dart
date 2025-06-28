import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeExtensions on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;

  // Direct access to all colors
  Color get primaryColor => appColors.primary;
  Color get backgroundColor => appColors.background;
  Color get thirdColor => appColors.thirdColor;
  Color get correctColor => appColors.correct;
  Color get wrongColor => appColors.wrong;
  Color get ctaColor => appColors.cta;
}