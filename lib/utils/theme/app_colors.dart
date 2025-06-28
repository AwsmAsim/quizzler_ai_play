import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color background;
  final Color thirdColor;
  final Color correct;
  final Color wrong;
  final Color cta;

  const AppColors({
    required this.primary,
    required this.background,
    required this.thirdColor,
    required this.correct,
    required this.wrong,
    required this.cta,
  });

  @override
  ThemeExtension<AppColors> copyWith() => this;

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) => this;
}