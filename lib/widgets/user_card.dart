import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String skills;
  final String imagePath;
  final String status; // online/offline

  const UserCard({
    super.key,
    required this.name,
    required this.skills,
    required this.imagePath,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOnline = status == 'online';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: AssetImage(imagePath),
            backgroundColor: Colors.grey.shade200,
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        skills,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black54,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 22,
        color: Colors.black45,
      ),
    );
  }
}
