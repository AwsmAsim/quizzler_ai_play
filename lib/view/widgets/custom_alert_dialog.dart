import 'package:flutter/material.dart';

class CustomAlertDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    String? tertiaryButtonText,
    VoidCallback? onPrimaryButtonPressed,
    VoidCallback? onSecondaryButtonPressed,
    VoidCallback? onTertiaryButtonPressed,
    bool barrierDismissible = true,
    Widget? icon,
    Color? primaryButtonColor,
    Color? secondaryButtonColor,
    Color? tertiaryButtonColor,
  }) async {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;
    
    return await showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon,
                const SizedBox(height: 16),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (primaryButtonText != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop('primary');
                          if (onPrimaryButtonPressed != null) {
                            onPrimaryButtonPressed();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryButtonColor ?? primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          primaryButtonText,
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (secondaryButtonText != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop('secondary');
                          if (onSecondaryButtonPressed != null) {
                            onSecondaryButtonPressed();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: secondaryButtonColor ?? primaryColor,
                          side: BorderSide(
                            color: secondaryButtonColor ?? primaryColor,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          secondaryButtonText,
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (tertiaryButtonText != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop('tertiary');
                          if (onTertiaryButtonPressed != null) {
                            onTertiaryButtonPressed();
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: tertiaryButtonColor ?? Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          tertiaryButtonText,
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}