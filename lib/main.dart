import 'package:flutter/material.dart';
import 'package:medical_app/features/emergency_assistant.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:EmergencyAssistantPage()
    );
    
  }
}