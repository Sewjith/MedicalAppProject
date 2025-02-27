import 'package:flutter/material.dart';
import 'package:medical_app/features/appoinment_history/upcoming.dart';
import 'package:medical_app/features/appoinment_history/cancelled.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/appoinment_history/review.dart';
void main() {
  runApp(Appointment());
}

class Appointment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Appointment History',
      theme: ThemeData(
        primaryColor: AppPallete .primaryColor,
        fontFamily: 'Arial',
        primarySwatch: Colors.blue,
      ),
      home: CompletedAppointmentsPage(),
    );
  }
}

class CompletedAppointmentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Appointment',
          style: TextStyle(
            color: AppPallete .primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppPallete .whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: AppPallete .primaryColor),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Appointment()),);
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
                ElevatedButton(onPressed: (){},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    backgroundColor: AppPallete .primaryColor,
                    foregroundColor:  AppPallete .whiteColor,
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
                    backgroundColor:  AppPallete .lightBackground,
                    foregroundColor:  AppPallete .primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Upcoming',
                    style: TextStyle(fontSize: 18),),
                ),
                SizedBox(width: 10),
                ElevatedButton(onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Cancel()),);
                },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete .lightBackground,
                    foregroundColor:  AppPallete .primaryColor,
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
          ),
          Expanded(
            child: ListView(
              children: [
                AppointmentCard(
                  doctorName: "Dr. Olivia Turner, M.D.",
                  specialty: "Dermato-Endocrinology",
                  rating: 5,
                  imageUrl: "assets/images/doc2.jpeg",
                  onRebook: () {},
                  onAddReview: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => review()));
                  },
                ),
                AppointmentCard(
                  doctorName: "Dr. Alexander Bennett, Ph.D.",
                  specialty: "Dermato-Genetics",
                  rating: 4,
                  imageUrl: "assets/images/doc1.jpeg",
                  onRebook: () {},
                  onAddReview: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => review()));
                  },
                ),
                AppointmentCard(
                  doctorName: "Dr. Sophia Martinez, Ph.D.",
                  specialty: "Cosmetic Bioengineering",
                  rating: 5,
                  imageUrl: "assets/images/doc3.png",
                  onRebook: () {},
                  onAddReview: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => review()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2,
        onItemTapped: (index) {},
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
          backgroundColor: isSelected ?  AppPallete .primaryColor :  AppPallete .greyColor,
          foregroundColor: isSelected ?  AppPallete .whiteColor :  AppPallete.textColor,
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
  final VoidCallback onRebook;
  final VoidCallback onAddReview;

  AppointmentCard({
    required this.doctorName,
    required this.specialty,
    required this.rating,
    required this.imageUrl,
    required this.onRebook,
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
            //
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor's profile image.
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
                          color:  AppPallete .primaryColor,
                        ),
                      ),
                      Text(
                        specialty,
                        style: TextStyle(color:  AppPallete.textColor),
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:  AppPallete .whiteColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Star icons (blue)
                            Row(
                              children: List.generate(
                                5,
                                    (index) => Icon(
                                  index < rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color:  AppPallete .primaryColor,
                                  size: 16,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            // Heart icon (blue)
                            Icon(
                              Icons.favorite,
                              color:  AppPallete .primaryColor,
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
            // Buttons row.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  AppPallete .whiteColor,
                    foregroundColor:  AppPallete .primaryColor,
                  ),
                  onPressed: onRebook,
                  child: Text("Re-Book"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  AppPallete .primaryColor,
                    foregroundColor: AppPallete .whiteColor,
                  ),
                  onPressed: onAddReview,
                  child: Text("Add Review"),
                ),
              ],
            )
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
        title: Text("Add Review", style: TextStyle(color:  AppPallete .primaryColor)),
        backgroundColor:  AppPallete .whiteColor,
        iconTheme: IconThemeData(color:  AppPallete .primaryColor),
        elevation: 0,
      ),
      body: Center(
        child: Text("Review Page", style: TextStyle(fontSize: 24)),
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
      selectedItemColor:  AppPallete .primaryColor,
      unselectedItemColor:  AppPallete .greyColor,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "", // Empty label (icon only)
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: "", // Empty label (icon only)
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "", // Empty label (icon only)
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "", // Empty label (icon only)
        ),
      ],
    );
  }
}