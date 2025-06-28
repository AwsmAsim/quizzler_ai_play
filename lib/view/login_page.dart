import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizzler/utils/theme/theme_extention.dart';
import 'package:quizzler/view/home_page.dart';
import 'package:quizzler/view/question_generator_form.dart';
import 'package:quizzler/view/signup_page.dart';
import 'package:quizzler/controller/auth_controller.dart';
import 'package:get/get.dart';
import 'package:quizzler/utils/smooth_navigator.dart';

import '../utils/constants.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: context.primaryColor,
            )),
      ),
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Padding(
              padding: EdgeInsets.all(SizeConstants.defaultPadding),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon with animation
                    AnimatedOpacity(
                      opacity: 1,
                      duration: Duration(milliseconds: 500),
                      child: Image.asset(
                        'assets/images/qizzler-play-logo-no-play-icon.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    SizedBox(height: SizeConstants.defaultPadding),

                    Text(
                      "Welcome Back",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                    ),

                    SizedBox(height: SizeConstants.defaultPadding),

                    Text(
                      "Login to continue",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: context.primaryColor,
                      ),
                    ),

                    SizedBox(height: SizeConstants.defaultPadding * 2),

                    // Email Field
                    _buildInputField(
                      context: context,
                      hintText: 'Email',
                      icon: Icons.email,
                      controller: _emailController,
                    ),
                    SizedBox(height: SizeConstants.defaultPadding),

                    // Password Field
                    _buildInputField(
                      context: context,
                      hintText: 'Password',
                      icon: Icons.lock,
                      isPassword: true,
                      controller: _passwordController,
                    ),
                    SizedBox(height: SizeConstants.defaultPadding * 1.5),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  final user = await _authController
                                      .signInWithEmailPassword(
                                    context,
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                  );

                                  if (user != null) {
                                    SmoothNavigator.pushReplacement(
                                        context, QuestionGeneratorForm());
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Login failed. Please check your credentials.'),
                                        backgroundColor: context.wrongColor,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('An error occurred: $e'),
                                      backgroundColor: context.wrongColor,
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              },
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Log In',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Forgot Password
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(
                          color: context.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    SizedBox(height: SizeConstants.defaultPadding),

                    // Sign up option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.poppins(
                            color: context.thirdColor,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            SmoothNavigator.push(context, SignupPage());
                          },
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(
                              color: context.ctaColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: GoogleFonts.poppins(color: context.primaryColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.grey),
        prefixIcon: Icon(icon, color: context.thirdColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.ctaColor, width: 1.5),
        ),
      ),
    );
  }
}
