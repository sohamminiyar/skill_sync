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
      'status': 'online',
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
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search connections',
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),

          // User list
          Expanded(
            child: ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                thickness: 0.6,
                indent: 72, // aligns with avatar
                color: Color(0xFFE0E0E0),
              ),
              itemBuilder: (context, index) {
                final user = users[index];
                return UserCard(
                  name: user['name']!,
                  skills: user['skills']!,
                  imagePath: user['image']!,
                  status: user['status']!,
                );
              },
            ),
          ),

          // Footer
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "No more connections",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
