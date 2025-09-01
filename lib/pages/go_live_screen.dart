import 'package:flutter/material.dart';

class GoLiveScreen extends StatefulWidget {
  static const String routeName = '/golive'; // 👈 added route name

  const GoLiveScreen({super.key});

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
