import 'package:flutter/material.dart';
import 'package:skillsync/utils/colors.dart';

class CustomTextfiled extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;

  const CustomTextfiled({
    super.key,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w300,
        fontSize: 12,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF808080), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF808080), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}