import 'package:flutter/material.dart';

class JustButtonPage extends StatelessWidget {
  const JustButtonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Just Button")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {},
          child: const Text("submit"),
        ),
      ),
    );
  }
}