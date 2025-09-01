import 'package:flutter/material.dart';
import 'package:skillsync/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CustomButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF65009),
        minimumSize: const Size(double.infinity, 70), // Height remains 70
        maximumSize: const Size(double.infinity * 0.5, 70), // Reduced to 50% width
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        shadowColor: Colors.black26,
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: 22,
        ),
      ),
    );
  }
}