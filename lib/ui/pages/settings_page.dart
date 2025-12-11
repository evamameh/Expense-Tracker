import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1C14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1C14),
        title: const Text("Settings"),
      ),
      body: const Center(
        child: Text(
          "Settings Page",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
