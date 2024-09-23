import 'package:flutter/material.dart';

class HomeUserpage extends StatefulWidget {
  const HomeUserpage({super.key});

  @override
  State<HomeUserpage> createState() => _HomeUserpageState();
}

class _HomeUserpageState extends State<HomeUserpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF412160),
      appBar: AppBar(),
      body: Center(
        child: const Text(
          'HomeUser',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
