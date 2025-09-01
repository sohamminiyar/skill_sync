import 'package:flutter/material.dart';
import 'package:skillsync/widgets/user_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> users = [
    {
      'name': 'Sam',
      'skills': 'Leadership, Team Management',
      'image': 'assets/sam.png',
      'status': 'online', // You can add status later for UI indications
    },
    {
      'name': 'Vatalik',
      'skills': 'Blockchain, P2P Expert',
      'image': 'assets/vatalik.png',
      'status': 'offline',
    },
    {
      'name': 'Shawn',
      'skills': 'Music, Entertainment',
      'image': 'assets/shawn.png',
      'status': 'online',
    },
    {
      'name': 'David',
      'skills': 'Gym, Nutrition',
      'image': 'assets/david.png',
      'status': 'online',
    },
    {
      'name': 'Vikas',
      'skills': 'Cooking',
      'image': 'assets/vikas.png',
      'status': 'offline',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFFD9D9D9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          const Divider(
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFFD9D9D9),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return UserCard(
                  name: user['name']!,
                  skills: user['skills']!,
                  imagePath: user['image']!,
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Text(
              "No More Connections",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

