import 'package:flutter/material.dart';
import 'package:quizzler/model/option_model.dart';
import 'package:quizzler/model/question_model.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';

class OptionCard extends StatelessWidget {
  final Option option;
  final bool isSelected;
  final bool showCorrect;
  final VoidCallback onTap;

  const OptionCard({
    Key? key,
    required this.option,
    required this.isSelected,
    required this.showCorrect,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;

    if (showCorrect) {
      backgroundColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.green;
      textColor = Colors.green.shade800;
      trailingIcon = Icons.check_circle;
    } else if (isSelected) {
      backgroundColor = context.primaryColor.withOpacity(0.1);
      borderColor = context.primaryColor;
      textColor = context.primaryColor;
      trailingIcon = Icons.radio_button_checked;
    } else {
      backgroundColor = Colors.white;
      borderColor = Colors.grey.shade300;
      textColor = Colors.black87;
      trailingIcon = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: Center(
                child: Text(
                  option.id,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'poppins',
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontFamily: 'poppins',
                ),
              ),
            ),
            if (trailingIcon != null)
              Icon(
                trailingIcon,
                color: textColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
