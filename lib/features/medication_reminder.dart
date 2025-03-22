import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/core/bottom_nav.dart';
import 'package:medical_app/features/Vaccination_Reminder.dart';
import 'package:medical_app/features/pillDetails.dart';

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

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppPallete.transparentColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_sharp, color: AppPallete.headings),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Placeholder()));
          },
        ),
        title:
        Text(
          "Today's plan",
          style: TextStyle(
              color: AppPallete.headings,
              fontWeight: FontWeight.bold,
              fontSize: 35
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.vaccines_outlined, color: AppPallete.headings,),
    onPressed: () {
      Navigator.push(
        context, MaterialPageRoute(builder: (context) => Vaccination()),);
    }
          ),
        ],
      ),
      body: SafeArea(
          child: Padding(padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Friday, 23 Nov 2024",
                style: TextStyle(
                  color: AppPallete.textColor,
                  fontSize: 16
                ),
              ),
              SizedBox(height: 20),
              Expanded(child: ListView.builder(
                itemCount: pillPlan.length,
                itemBuilder: (context, index) {
                  return PillCard(
                    time: pillPlan[index]['time']!,
                    name: pillPlan[index]['name']!,
                    details: pillPlan[index]['details']!,
                  );
                },
              ),
              ),
            ],
          ),
          ),
      ),
    );
  }
}
class PillCard extends StatelessWidget{
  final String time;
  final String name;
  final String details;

  const PillCard({
    required this.time,
    required this.name,
    required this.details
});
  @override
  Widget build (BuildContext context){
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppPallete.textColor
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.medication_rounded, color: AppPallete.headings, size: 40,),
              SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                  Text(
                    details,
                    style: TextStyle(
                      fontSize: 14, color: Colors.black45
                    ),
                  ),
                ],
              ),),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios_outlined, color: Colors.black45,),
                onPressed: (){
                  Navigator.push(context,
                  MaterialPageRoute(builder:(context) => pillDetails(
                    name: name,
                    details: details
                  ),),);
                },
              ),
            ],
          )),
        )
      ],
    );
  }
}

