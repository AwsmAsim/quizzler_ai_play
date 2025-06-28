import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_colors.dart';

class Themes {
  // static const Color primaryColor = Color(0xFF2A4B7C);
  // static const Color thirdColor = Color(0xFFC5A46D);
  // static const Color correctColor = Color(0xFF80C783);
  // static const Color wrongColor = Color(0xFFFF8080);
  // static const Color ctaColor = Color(0xFFC5A46D);

  static Color primaryColor = Color(0xFF6E41E2);  // Bold purple (energetic yet professional)
  static Color secondaryColor = Color(0xFF00C1B6); // Teal (fresh contrast)
  static Color thirdColor = Color(0xFFFFA726);   // Warm orange-gold (modern accent)
  static Color correctColor = Color(0xFF9CFF8E);  // Vibrant lime green
  static Color wrongColor = Color(0xFFFF6F6F);    // Coral red (softer but attention-grabbing)
  static Color ctaColor = Color(0xFFFFA726);

  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: thirdColor,
      background: const Color(0xFFF5F5F5),
      surface: Colors.white,
      error: wrongColor,
    ),
    extensions: <ThemeExtension<dynamic>>[
      AppColors(
        correct: correctColor,
        wrong: wrongColor,
        cta: ctaColor,
        primary: primaryColor,
        background: const Color(0xFFF5F5F5),
        thirdColor: thirdColor,
      ),
    ],
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF4A6B9C),
      secondary: const Color(0xFFD4B47D),
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      error: wrongColor,
    ),
    extensions: <ThemeExtension<dynamic>>[
      AppColors(
        correct: correctColor,
        wrong: wrongColor,
        cta: ctaColor,
        primary: primaryColor,
        background: const Color(0xFFF5F5F5),
        thirdColor: thirdColor,
      ),
    ],
  );
}