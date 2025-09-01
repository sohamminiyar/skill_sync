// lib/models/user.dart
class User {
  final String uid;
  final String username;
  final String email;
  final String? skills; // New field
  final String? profileImageUrl; // New field

  User({
    required this.uid,
    required this.username,
    required this.email,
    this.skills,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'skills': skills,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      skills: map['skills'],
      profileImageUrl: map['profileImageUrl'],
    );
  }
}