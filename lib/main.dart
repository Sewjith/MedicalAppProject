import 'package:flutter/material.dart';
import 'package:medical_app/features/Vaccination_Reminder.dart';
import 'package:medical_app/features/medication_reminder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReminderPage()
    );
    
  }
}