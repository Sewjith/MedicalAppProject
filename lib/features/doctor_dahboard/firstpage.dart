import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor_dahboard/patient_list.dart';
import 'package:medical_app/features/doctor_dahboard/inbox.dart';
import 'package:medical_app/features/doctor_dahboard/earnings.dart';
import 'package:medical_app/features/doctor_dahboard/overview.dart';
 // Import EarningsPage

void main() {
  runApp(DoctorDashboard());
}

class DoctorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isHoveredPatientList = false;
  bool _isHoveredInbox = false;
  bool _isHoveredEarnings = false;
  bool _isHoveredOverview = false;
  bool _isHoveredSettings = false;

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget drawerItem(String title, BuildContext context, bool isHovered, Function(bool) onHover) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: AppPallete.whiteColor,
            decoration: isHovered ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (title == "PATIENT LIST") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PatientListPage()),
            );
          } else if (title == "INBOX") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InboxPage()),
            );
          }  else if (title == "Earnings") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EarningsPage()),
            );
          } else if (title == "OVERVIEW") {
            Navigator.push(
             context,
              MaterialPageRoute(builder: (context) => OverviewPage()),
            );
          }

        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.secondaryColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: AppPallete.primaryColor),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: AppPallete.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: AppPallete.primaryColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: AppPallete.primaryColor),
                child: Text(
                  "MENU",
                  style: TextStyle(fontSize: 24, color: AppPallete.whiteColor),
                ),
              ),
              drawerItem("PATIENT LIST", context, _isHoveredPatientList, (hovered) {
                setState(() {
                  _isHoveredPatientList = hovered;
                });
              }),
              drawerItem("INBOX", context, _isHoveredInbox, (hovered) {
                setState(() {
                  _isHoveredInbox = hovered;
                });
              }),
              drawerItem("Earnings", context, _isHoveredEarnings, (hovered) {
                setState(() {
                  _isHoveredEarnings = hovered;
                });
              }),
              drawerItem("OVERVIEW", context, _isHoveredOverview, (hovered) {
                setState(() {
                  _isHoveredOverview = hovered;
                });
              }),
              drawerItem("SETTINGS", context, _isHoveredSettings, (hovered) {
                setState(() {
                  _isHoveredSettings = hovered;
                });
              }),
            ],
          ),
        ),
      ),
      body: Container(
        color: AppPallete.secondaryColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppPallete.primaryColor,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Hi ! Smith',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: AppPallete.whiteColor,
                      ),
                    ),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 35,
                        color: AppPallete.whiteColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    CircleAvatar(
                      radius: 120,
                      backgroundColor: AppPallete.whiteColor,
                      backgroundImage: AssetImage('assets/images/doctor1.jpg'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Dr.Smith',
                      style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold, color: AppPallete.textColor),
                    ),
                    Text(
                      'Cardiologist',
                      style: TextStyle(fontSize: 23, color: AppPallete.borderColor),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
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
      selectedItemColor: AppPallete.primaryColor,
      unselectedItemColor: AppPallete.greyColor,
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
