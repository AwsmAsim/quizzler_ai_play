import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:quizzler/controller/auth_controller.dart';
import 'package:quizzler/utils/constants.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';

class EditDetailsPage extends StatefulWidget {
  const EditDetailsPage({Key? key}) : super(key: key);

  @override
  _EditDetailsPageState createState() => _EditDetailsPageState();
}

class _EditDetailsPageState extends State<EditDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Pre-fill the name field with the current display name
    _nameController.text = _authController.currentUser.value?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          'Edit Details',
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
                    inputShadowWidget(
                      title: 'Display Name',
                      child: TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your display name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter your name',
                          hintStyle: TextStyle(
                            fontFamily: 'poppins',
                            color: context.primaryColor,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
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
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  final name = _nameController.text.trim();
                  try {
                    _authController.isUpdatingDisplayName.value = true;
                    bool success = await _authController.updateUserDisplayName(
                        context, name);

                    if (success && context.mounted) {
                      Navigator.of(context).pop(); // Go back to settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Display name updated!')),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Failed to update display name')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  } finally {
                    _authController.isUpdatingDisplayName.value = false;
                  }
                },
                child: Obx(
                  () => _authController.isUpdatingDisplayName.value
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.backgroundColor,
                          ),
                        )
                      : Text(
                          'Save',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.backgroundColor,
                          ),
                        ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: context.backgroundColor,
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
