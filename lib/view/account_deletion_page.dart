import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:quizzler/controller/auth_controller.dart';
import 'package:quizzler/utils/constants.dart';
import 'package:quizzler/utils/smooth_navigator.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';
import 'login_options_page.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({Key? key}) : super(key: key);

  @override
  _AccountDeletionPageState createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  bool _isDeleting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Widget inputShadowWidget({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontFamily: 'poppins'),
        ),
        SizedBox(
          height: SizeConstants.defaultPadding / 2,
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConstants.defaultPadding / 2),
            child: Center(
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: context.primaryColor),
        title: Text(
          'Delete Account',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: context.primaryColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'We’re Sad to See You Go',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: context.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Thank you for being a part of Quizzler. We’ve loved having you here, and it’s hard to say goodbye. Before you leave, we’d appreciate your feedback to help us improve. Your thoughts mean the world to us!',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    inputShadowWidget(
                      title: 'Feedback (Optional)',
                      child: TextFormField(
                        controller: _feedbackController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Please share your feedback...',
                          hintStyle: TextStyle(
                            fontFamily: 'poppins',
                            color: context.primaryColor,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Are you sure you want to delete your account? This action cannot be undone.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: SizeConstants.defaultPadding),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: Container(
              padding: EdgeInsets.symmetric(
                  vertical: SizeConstants.defaultPadding,
                  horizontal: SizeConstants.defaultPadding),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isDeleting
                    ? null
                    : () async {
                        setState(() {
                          _isDeleting = true;
                        });
                        try {
                          // Save feedback and user details to Firestore
                          await FirebaseFirestore.instance
                              .collection('account_deletion_feedback')
                              .add({
                            'userId': _authController.currentUser.value?.uid,
                            'email': _authController.currentUser.value?.email,
                            'displayName':
                                _authController.currentUser.value?.displayName,
                            'feedback': _feedbackController.text.trim(),
                            'timestamp': FieldValue.serverTimestamp(),
                          });

                          await _authController.currentUser.value?.delete();
                          await _authController.signOut(context);
                          if (context.mounted) {
                            SmoothNavigator.pushReplacement(
                                context, LoginOptionsPage());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Account deleted successfully')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error deleting account: $e')),
                            );
                          }
                        } finally {
                          setState(() {
                            _isDeleting = false;
                          });
                        }
                      },
                child: _isDeleting
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Delete Account',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
