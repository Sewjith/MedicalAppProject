import 'package:flutter/material.dart';
import 'package:medical_app/features/appoinment_history/review2.dart';
import 'package:medical_app/features/appoinment_history/appoinment.dart';
import 'package:medical_app/features/appoinment_history/upcoming.dart';
import 'package:medical_app/features/appoinment_history/review2.dart';
import 'package:medical_app/core/themes/color_palette.dart';

void main() {
  runApp(Cancel());
}

class Cancel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Appointment History',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: CancelPage(),
    );
  }
}

class CancelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Appointment',
          style: TextStyle(
            color:  AppPallete.headings,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:  AppPallete.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color:  AppPallete.primaryColor),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => Appointment()));
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Appointment()),);
                    }, style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      backgroundColor:  AppPallete.lightBackground,
                      foregroundColor:  AppPallete.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                      child: const Text(
                        'Complete',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Upcoming()),);
                    },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        backgroundColor:  AppPallete.lightBackground,
                        foregroundColor:  AppPallete.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Upcoming',
                        style: TextStyle(fontSize: 18),),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(onPressed: () {
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  AppPallete.primaryColor,
                        foregroundColor:  AppPallete.whiteColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Cancelled',
                        style: TextStyle(fontSize: 18),),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                AppointmentCard(
                  doctorName: "Dr. Olivia Turner, M.D.",
                  specialty: "Dermato-Endocrinology",
                  rating: 5,
                  imageUrl: "assets/images/doc2.jpeg",
                  onAddReview: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => review2()));
                  },
                ),
                AppointmentCard(
                  doctorName: "Dr. Alexander Bennett, Ph.D.",
                  specialty: "Dermato-Genetics",
                  rating: 4,
                  imageUrl: "assets/images/doc2.jpeg",
                  onAddReview: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => review2()));
                  },
                ),
                AppointmentCard(
                  doctorName: "Dr. Sophia Martinez, Ph.D.",
                  specialty: "Cosmetic Bioengineering",
                  rating: 5,
                  imageUrl: "assets/images/doc3.png",
                  onAddReview: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => review2()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2, // Update as needed
        onItemTapped: (index) {
          // Handle navigation here
        },
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;

  FilterButton({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ?  AppPallete.primaryColor :  AppPallete.greyColor,
          foregroundColor: isSelected ?  AppPallete.whiteColor :  AppPallete.textColor,
        ),
        onPressed: () {},
        child: Text(label),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final int rating;
  final String imageUrl;
  final VoidCallback onAddReview;

  AppointmentCard({
    required this.doctorName,
    required this.specialty,
    required this.rating,
    required this.imageUrl,
    required this.onAddReview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color:  Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(imageUrl),
                  radius: 30,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:  AppPallete.primaryColor,
                        ),
                      ),
                      Text(
                        specialty,
                        style: TextStyle(color:  AppPallete.textColor),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color:  AppPallete.whiteColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                    (index) => Icon(
                                  index < rating ? Icons.star : Icons.star_border,
                                  color:  AppPallete.primaryColor,
                                  size: 16,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.favorite,
                              color:  AppPallete.primaryColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 270,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  AppPallete.primaryColor,
                      foregroundColor:  AppPallete.whiteColor,
                    ),
                    onPressed: onAddReview,
                    child: Text("Add Review"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Review", style: TextStyle(color:  AppPallete.primaryColor)),
        backgroundColor: AppPallete.whiteColor,
        iconTheme: IconThemeData(color:  AppPallete.primaryColor),
        elevation: 0,
      ),
      body: Center(
        child: Text("Review Page", style: TextStyle(fontSize: 24, color:  AppPallete.textColor)),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  BottomNavBar({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor:  AppPallete.primaryColor,
      unselectedItemColor:  AppPallete.greyColor,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "",
        ),
      ],
    );
  }
}