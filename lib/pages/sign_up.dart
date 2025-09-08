import 'package:flutter/material.dart';
import 'package:skillsync/pages/home_screen.dart';
import 'package:skillsync/resources/auth_methods.dart';
import 'package:skillsync/widgets/custom%20button.dart';
import 'package:skillsync/widgets/custom_textfiled.dart';



class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void signUpUser() async {
    bool res = await _authMethods.signUpUser(
      context,
      _emailController.text,
      _usernameController.text,
      _passwordController.text,
    );
    if (res) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    }
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
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Sync ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 40,
                          color: Colors.black,
                        ),
                      ),
                      const TextSpan(
                        text: 'Up\n',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 40,
                          color: Color(0xFF0C8CE9),
                        ),
                      ),
                      const TextSpan(
                        text: 'Skill ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 40,
                          color: Colors.black,
                        ),
                      ),
                      const TextSpan(
                        text: 'Up!',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 40,
                          color: Color(0xFF8A38F5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.1),
              const Text(
                'Username',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CustomTextfiled(controller: _usernameController),
              ),
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
                child: CustomTextfiled(controller: _passwordController),
              ),
              SizedBox(height: size.height * 0.05),
              Center(
                child: SizedBox(
                  width: size.width * 0.5,
                  child: CustomButton(text: 'Register', onTap: signUpUser),
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Already have an Account?",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Login',
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