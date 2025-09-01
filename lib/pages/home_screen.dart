import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillsync/pages/feed_screen.dart';
import 'package:skillsync/pages/go_live_screen.dart';
import 'package:skillsync/pages/chat_screen.dart';
import 'package:skillsync/providers/user_provider.dart';
import 'package:skillsync/models/user.dart' as model;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillsync/pages/login_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;

  final List<Widget> pages = [
    const FeedScreen(),
    const GoLiveScreen(),
    const ChatScreen(),
  ];

  void onPageChange(int index) {
    setState(() {
      _page = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // currently unused, can be removed if not required
    // final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF65009),
        automaticallyImplyLeading: false,
        title: const Text(
          'SkillSync',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 32,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0.0, 2.0),
                blurRadius: 4.0,
                color: Colors.black45,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // main page content
          Expanded(child: pages[_page]),

          // SafeArea to avoid overlap
          SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // slogan container
                Container(
                  color: const Color(0xFF1E1E1E),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child:  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                        children: const [
                          TextSpan(text: "Share "),
                          TextSpan(
                            text: "Skills",
                            style: TextStyle(color: Color(0xFFF316B0)), // pink
                          ),
                          TextSpan(text: ", Build "),
                          TextSpan(
                            text: "Bonds!",
                            style: TextStyle(color: Color(0xFFF65009)), // orange
                          ),
                        ],
                      ),
                    ),
                  )

                ),

                // custom bottom nav bar
                Container(
                  height: 70,
                  color: const Color(0xFF1E1E1E),
                  child: Row(
                    children: [
                      _buildTab(Icons.explore, "Explore", 0),
                      _buildTab(Icons.add_rounded, "Go Live", 1),
                      _buildTab(Icons.chat_bubble_outline, "Chats", 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Custom Tab that fills 1/3 of the screen
  Widget _buildTab(IconData icon, String label, int index) {
    final isSelected = _page == index;
    return Expanded(
      child: InkWell(
        onTap: () => onPageChange(index),
        child: Container(
          color: isSelected ? Colors.black : Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
