import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  
  final String doctorImagePath;
  final String rating;
  final String doctorName;
  final String doctorProfession;
  final String DoctorEarning;

  const DoctorCard({super.key, 
    required this.doctorImagePath,
    required this.rating,
    required this.doctorName,
    required this.doctorProfession,
    required this.DoctorEarning
  });

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: Container(
        padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.deepPurple[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child:Image.asset(
                  doctorImagePath,
                   height: 100,),
                ),
                const SizedBox(
                  height: 10,
                ),
                //rating
                Row(
                  children: [
                    Icon(Icons.star,
                    color: Colors.yellow[600],
                    ),
                    Text(
                      rating,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold
                    ),)
              ]),
              const SizedBox(
                height: 10,
              ),
              //doc name
              Text(
                doctorName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),),
              const SizedBox(
                height: 10,
              ),
              Text(
                '$doctorProfession 7 y.exp',
              ),
              Text(
                DoctorEarning,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),),
              ],
              //doc name
              
              
            
            ),
          ),
        ),
    );
  }
}