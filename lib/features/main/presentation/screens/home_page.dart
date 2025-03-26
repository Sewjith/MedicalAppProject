import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text(
        'Demo',
        style: TextStyle(color: Color.fromARGB(255, 17, 17, 17)),
      ),
    );
  }
}
