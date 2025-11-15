import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:skillsync/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CustomButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF65009),
        minimumSize: const Size(double.infinity, 70), // Full width (mobile)
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

    // Apply max width constraint only on web
    return kIsWeb
        ? Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250), // max width on web
        child: button,
      ),
    )
        : button;
  }
}
