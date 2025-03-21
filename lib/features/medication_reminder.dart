import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/core/bottom_nav.dart';

void main(){
  runApp(Medication_Reminder());
}

class Medication_Reminder extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReminderPage(),
    );
  }
}
class ReminderPage extends StatelessWidget{
  final List<Map<String, String>> pillPlan= [
    {'time': '8:00', 'name': 'Omega 3', 'details': '1 pill once per day'},
    {'time': '12:30', 'name': 'Vitamin D', 'details': '2 pills once per day'},
    {'time': '18:00', 'name': 'Vitamin C', 'details': '1 pill once per day'},
    {'time': '21:00', 'name': 'Aspirin', 'details': '1 pill once per day'}
  ];
}

