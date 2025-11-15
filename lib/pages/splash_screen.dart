import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:skillsync/pages/login_screen.dart';
import 'package:skillsync/pages/home_screen.dart';
import 'package:skillsync/responsive/responsive.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/onboarding';
  final bool isLoggedIn;

  const SplashScreen({super.key, this.isLoggedIn = false});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> programmerWidth;
  late Animation<double> pianistHeight;
  late Animation<double> socialiteHeight;
  late Animation<double> leadershipLength;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      // Only create animation controller on mobile
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      );
      _controller.forward();
    }

    // Common navigation after 2s
    Future.delayed(const Duration(seconds: 2), () {
      if (widget.isLoggedIn) {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      } else {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      }
    });
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // WEB → show static splash image (full screen)
      return Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: Image.asset(
            'assets/splash_screen.png',
            fit: BoxFit.cover, // covers the entire screen
          ),
        ),
      );
    }

    // MOBILE → show animated splash
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    programmerWidth = Tween<double>(
      begin: screenWidth * 0.25,
      end: screenWidth * 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    pianistHeight = Tween<double>(
      begin: 0,
      end: screenHeight * 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    socialiteHeight = Tween<double>(
      begin: screenHeight * 0.1,
      end: screenHeight * 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    leadershipLength = Tween<double>(
      begin: screenWidth * 1.0,
      end: screenWidth * 5.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Responsive(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Pianist rectangle
                Positioned(
                  left: screenWidth * 0.1,
                  bottom: 0,
                  child: Container(
                    width: screenWidth * 0.15,
                    height: pianistHeight.value,
                    color: const Color(0xFFF65009),
                    alignment: Alignment.center,
                    child: const RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'Pianist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

                // Programmer rectangle
                Positioned(
                  left: 0,
                  top: screenHeight * 0.1,
                  child: Container(
                    width: programmerWidth.value,
                    height: screenHeight * 0.08,
                    color: const Color(0xFF8A38F5),
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                    child: const Text(
                      'Programmer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                // Socialite rectangle
                Positioned(
                  right: screenWidth * 0.05,
                  top: 0,
                  child: Container(
                    width: screenWidth * 0.15,
                    height: socialiteHeight.value,
                    color: const Color(0xFFF316B0),
                    alignment: Alignment.center,
                    child: const RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'Socialite',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

                // Leadership rectangle
                Positioned(
                  left: screenWidth / 2 - leadershipLength.value / 2,
                  top: screenHeight * 0.05,
                  child: Transform.rotate(
                    angle: pi / 4,
                    alignment: Alignment.center,
                    child: Container(
                      width: leadershipLength.value,
                      height: screenHeight * 0.08,
                      color: Colors.blue,
                      alignment: Alignment.center,
                      child: const Text(
                        'Leadership',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),

                // Logo
                Center(
                  child: Image.asset(
                    'assets/skillsync_logo.png',
                    width: screenWidth * 0.6,
                    height: screenWidth * 0.6,
                  ),
                ),

                // Caption text
                Positioned(
                  left: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                  bottom: screenHeight * 0.03,
                  child: const Text(
                    'A free, open-source platform for students to share skills, break hierarchies, and build connections.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
