import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/core/bottom_nav.dart';
import 'package:medical_app/features/medication_reminder.dart';

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
      backgroundColor: AppPallete.whiteColor,
        appBar: AppBar(
        elevation: 0,
        backgroundColor: AppPallete.transparentColor,
        leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_sharp, color: AppPallete.headings),
    onPressed: () {
    Navigator.pushReplacement(
    context, MaterialPageRoute(builder: (context) => ReminderPage()));
    },
    ),
        title:
        Text(
          "Today's Plan",
          style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: AppPallete.headings
          ),
        ),
          centerTitle: true,
        ),
    body: SafeArea(
    child: Padding(padding: const EdgeInsets.all(20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
      'Friday, 23 Nov 2024',
      style: TextStyle(
    color: AppPallete.textColor,
        fontSize: 16
    ),
      ),
      SizedBox(height: 20),
      Expanded(child: ListView.builder(
        itemCount: vaccinePlan.length,
        itemBuilder: (context, index){
          return vaccineCard(
            name: vaccinePlan[index]['name']!,
            details: vaccinePlan[index]['details']!
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
class vaccineCard extends StatelessWidget{
  final String name;
  final String details;

  const vaccineCard({
    required this.name,
    required this.details
});
  @override
  Widget build (BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.vaccines_outlined, color: AppPallete.headings,
                    size: 40,),
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
                ],
              )),
        )
      ],
    );
  }
}