import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/Patient/appoinment_history/cancelled.dart';

void main() {
  runApp(review2());
}

class review2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Appointment History',
      theme: ThemeData(
        fontFamily: 'Arial',
      ),
      home: ReviewPage2(),
    );
  }
}

class ReviewPage2 extends StatefulWidget {
  @override
  _ReviewPage2State createState() => _ReviewPage2State();
}

class _ReviewPage2State extends State<ReviewPage2> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppPallete.whiteColor,
      appBar: AppBar(
        backgroundColor:  AppPallete.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color:  AppPallete.primaryColor),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => CancelledAppointmentsList()));
          },
        ),
        centerTitle: true,
        title: Text(
          'Review',
          style: TextStyle(
            color:  AppPallete.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Your feedback helps us improve your healthcare experience. Please share your thoughts about the consultation.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color:  AppPallete.textColor),
            ),
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/doc2.jpeg'),
            ),
            SizedBox(height: 10),
            Text(
              'Dr. Olivia Turner, M.D.',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color:  AppPallete.primaryColor,
              ),
            ),
            Text(
              'Dermato-Endocrinology',
              style: TextStyle(fontSize: 14, color:  AppPallete.textColor),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, color:  AppPallete.primaryColor),
                SizedBox(width: 5),
                Row(
                  children: List.generate(5, (index) => Icon(Icons.star, color:  AppPallete.primaryColor)),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter Your Comment Here…',
                filled: true,
                fillColor:  Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor:  AppPallete.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text('Add Review', style: TextStyle(fontSize: 16, color:  AppPallete.whiteColor)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
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