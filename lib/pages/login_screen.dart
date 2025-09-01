import 'package:flutter/material.dart';
import 'package:skillsync/pages/home_screen.dart';
import 'package:skillsync/pages/sign_up.dart';
import 'package:skillsync/resources/auth_methods.dart';
import 'package:skillsync/widgets/custom%20button.dart';
import 'package:skillsync/widgets/custom_textfiled.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  bool _isLoading = false;

  loginUser() async {
    setState(() {
      _isLoading = true;
    });
    bool res = await _authMethods.loginUser(
      context,
      _emailController.text,
      _passwordController.text,
    );
    setState(() {
      _isLoading = false;
    });
    if (res) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.2),
              Center(
                child: const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 40,
                  ),
                ),
              ),
              Center(
                child: const Text(
                  'SkillSync',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 40,
                    color: Color(0xFF8A38F5),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.1),
              const Text(
                'Email',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomTextfiled(controller: _emailController),
              ),
              const Text(
                'Password',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomTextfiled(
                  controller: _passwordController,
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Center( // Center the button to avoid full-width expansion
                child: SizedBox(
                  width: size.width * 0.5, // Explicitly set width to 50% of screen
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(text: 'Login', onTap: loginUser),
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, SignUpScreen.routeName);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Don't have an Account?",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Register',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFF316B0),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}