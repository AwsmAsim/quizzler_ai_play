import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    double? width,
    EdgeInsets margin = const EdgeInsets.all(8.0),
    ShapeBorder? shape,
    double elevation = 6.0,
    VoidCallback? onVisible,
  }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontFamily: 'poppins',
        ),
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      action: action,
      width: width,
      margin: margin,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: elevation,
      behavior: SnackBarBehavior.floating,
      onVisible: onVisible,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.red.shade800,
      duration: duration,
    );
  }
  
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.green.shade800,
      duration: duration,
    );
  }
  
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      backgroundColor: Colors.blue.shade800,
      duration: duration,
    );
  }
}