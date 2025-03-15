import 'package:flutter/material.dart';

class JustNamePage extends StatelessWidget {
  const JustNamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Name")),
      body: const Center(
        child: Text("AYESHA", style: TextStyle(fontSize: 30)),
      ),
    );
  }
}