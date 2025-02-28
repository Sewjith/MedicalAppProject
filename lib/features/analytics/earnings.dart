import 'package:flutter/material.dart';
import 'category_card.dart';
import 'doctor_card.dart';
import 'package:lottie/lottie.dart';


class Earnings extends StatefulWidget {
  const Earnings({super.key});

  @override
  State<Earnings> createState() => _EarningsState();
}

class _EarningsState extends State<Earnings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(child: 
       Column(children: [
        //app bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal:25.0 ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              Column( 
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text("Hello,",style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 18),),
                SizedBox(height: 8),
                Text("User",
                style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 24
                ),
                ),
              ],
              ),
              //Profile image
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[100],
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Icon(
                  Icons.person,
                  )
                ),
            ],
          ),
        ),
        SizedBox(height: 25),
        //card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0 ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.pink[100],
              borderRadius: BorderRadius.circular(12)
            ),
            child: Row(children: [
              //animation
              Container(
                height: 100,
                width: 100,
                child: Lottie.asset("assets/images/Animation - 1740714679870.json"),
                ),
                SizedBox(
                  width: 20,
                ),
              //how do u feel + button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text("Earnings this Month",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                  ),
                  SizedBox(height: 12),
                  Text("Find the Doctor",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[300],
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Center(
                      child: Text("Get Started",
                      style: TextStyle(color: Colors.white,),
                      )
                  ,)
                  ,)
                ],),
              )
            ],),
          ),
        ),
        SizedBox(height: 25),
        //search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple[100],
              borderRadius: BorderRadius.circular(12)
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Earning Search?",
                prefixIcon: Icon(Icons.search),
                border: InputBorder.none
              ),
            ),
          ),
        ),
        SizedBox(height: 25),

        //horizontal view - categories
        Container(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              CategoryCard(
                categoryName: "Dentist",
                iconImagePath: "lib/Icons/tooth.png",
              ),
              CategoryCard(
                categoryName: "Surgeon",
                iconImagePath: "lib/Icons/hospital.png",
              ),
              CategoryCard(
                categoryName: "Pharmacist",
                iconImagePath: "lib/Icons/capsules.png",
              ),
            ],
          ),
        ),

        SizedBox(height: 25),
        //doctor list
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Doctor List",
            style: TextStyle(fontWeight: FontWeight.bold,
            fontSize: 20,
            )
            ),
            Text("See All",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500]
            ),),
          ],
        ),
      ),
      SizedBox(height: 25),
      //doctor card
     Expanded(child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        DoctorCard(
          doctorImagePath: "lib/Images/doc1.jpg",
          rating: "4.5",
          doctorName: "Dr. Jake Doe",
          doctorProfession: "Dentist",
          DoctorEarning: "Rs. 500,000",
        ),
        DoctorCard(
          doctorImagePath: "lib/Images/doc2.jpg",
          rating: "4.0",
          doctorName: "Dr. Jane Reacher",
          doctorProfession: "Surgeon",
           DoctorEarning: "Rs. 150,000",
        ),
          DoctorCard(
          doctorImagePath: "lib/Images/doc3.jpg",
          rating: "5.0",
          doctorName: "Dr. Mary Doe",
          doctorProfession: "Intern",
           DoctorEarning: "Rs. 25,000",
        ),
      ],
     ))
      ],),
    ),
    // ignore: dead_code
    );
  }
}