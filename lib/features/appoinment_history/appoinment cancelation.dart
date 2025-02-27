import 'package:flutter/material.dart';
import 'package:medical_app/features/appoinment_history/upcoming.dart';
import 'package:medical_app/core/themes/color_palette.dart';

void main() {
  runApp(form());
}

class form extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Appointment History',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: CancelAppointmentPage(),
    );
  }
}

class CancelAppointmentPage extends StatefulWidget {
  @override
  _CancelAppointmentPageState createState() => _CancelAppointmentPageState();
}

class _CancelAppointmentPageState extends State<CancelAppointmentPage> {
  String selectedReason = 'Weather Conditions';
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
                MaterialPageRoute(builder: (context) => Upcoming()));
          },
        ),
        centerTitle: true,
        title: Text(
          'Cancel Appointment',
          style: TextStyle(
            color:  AppPallete.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please select the reason for cancelling your appointment.',
              style: TextStyle(fontSize: 14, color:  AppPallete.textColor),
            ),
            SizedBox(height: 20),
            buildRadioButton('Rescheduling'),
            buildRadioButton('Weather Conditions'),
            buildRadioButton('Unexpected Work'),
            buildRadioButton('Others'),
            SizedBox(height: 20),
            Text(
              'Provide additional details if needed.',
              style: TextStyle(fontSize: 14, color:  AppPallete.primaryColor),
            ),
            SizedBox(height: 10),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter Your Reason Here…',
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor:  AppPallete.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text('Cancel Appointment', style: TextStyle(fontSize: 16, color:  AppPallete.whiteColor)),
              ),
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

  Widget buildRadioButton(String title) {
    return ListTile(
      title: Text(title),
      leading: Radio(
        value: title,
        groupValue: selectedReason,
        activeColor:  AppPallete.primaryColor,
        onChanged: (value) {
          setState(() {
            selectedReason = value.toString();
          });
        },
      ),
      tileColor: selectedReason == title ?  AppPallete.primaryColor.withOpacity(0.2) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
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