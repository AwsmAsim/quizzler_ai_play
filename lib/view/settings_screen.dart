import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:quizzler/controller/auth_controller.dart';
import 'package:quizzler/utils/constants.dart';
import 'package:quizzler/utils/smooth_navigator.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';
import 'edit_details_page.dart';
import 'account_deletion_page.dart';
import 'login_options_page.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: context.primaryColor),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: context.primaryColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // Edit Details Option
          ListTile(
            leading: Icon(
              Icons.edit,
              color: context.primaryColor,
              size: 28,
            ),
            title: Text(
              'Edit Details',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: context.primaryColor,
              ),
            ),
            onTap: () {
              SmoothNavigator.push(context, EditDetailsPage());
            },
          ),

          // Divider
          Divider(
            color: Colors.grey.shade300,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),

          // Log Out Option
          ListTile(
            leading: Icon(
              Icons.logout,
              color: context.primaryColor,
              size: 28,
            ),
            title: Text(
              'Log Out',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: context.primaryColor,
              ),
            ),
            onTap: () async {
              await authController.signOut(context);
              SmoothNavigator.pushReplacement(context, LoginOptionsPage());
            },
          ),

          // Divider
          Divider(
            color: Colors.grey.shade300,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),

          // Delete Account Option
          ListTile(
            leading: Icon(
              Icons.delete,
              color: Colors.red,
              size: 28,
            ),
            title: Text(
              'Delete Account',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            onTap: () {
              SmoothNavigator.push(context, AccountDeletionPage());
            },
          ),
        ],
      ),
    );
  }
}
