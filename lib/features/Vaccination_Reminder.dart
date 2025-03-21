import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/core/bottom_nav.dart';

void main(){
  runApp(Vaccination_Reminder());
}

class Vaccination_Reminder extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Vaccination(),
    );
  }
}

class Vaccination extends StatelessWidget{
  final List<Map<String, String>> vaccinePlan= [
    {'name': 'Pneumococcal Vaccine', 'details': '1 dose'},
    {'name': 'Influenza Vaccine', 'details': '1 dose'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.headings,

    );
  }
}