import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final String doctorName;
  final String specialty;
  final String appointmentDate;
  final String appointmentTime;

  const AppointmentDetailsPage({
    Key? key,
    required this.doctorName,
    required this.specialty,
    required this.appointmentDate,
    required this.appointmentTime,
  }) : super(key: key);

  @override
  _AppointmentDetailsPageState createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  AppPallete.whiteColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color:  AppPallete.primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Appointment Details',
          style: TextStyle(color:  AppPallete.primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doctor: ${widget.doctorName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              'Specialization: ${widget.specialty}',
              style: TextStyle(fontSize: 14, color:  AppPallete.greyColor),
            ),
            Divider(),
            SizedBox(height: 10),
            Text('Appointment ID: APT001',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, color:  AppPallete.primaryColor),
                SizedBox(width: 10),
                Text(widget.appointmentDate, // Use the appointmentDate parameter here
                    style: TextStyle(fontSize: 16, color:  AppPallete.textColor)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.access_time, color:  AppPallete.primaryColor),
                SizedBox(width: 10),
                Text(widget.appointmentTime,
                    style: TextStyle(fontSize: 16, color:  AppPallete.textColor)),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Patient Name: John Doe',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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