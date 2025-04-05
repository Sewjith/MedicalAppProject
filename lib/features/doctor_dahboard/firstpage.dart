import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor_dahboard/appoinment.dart';
import 'package:medical_app/features/doctor_dahboard/patient_list.dart';
import 'package:medical_app/features/doctor_dahboard/inbox.dart';
import 'package:medical_app/features/doctor_dahboard/earnings.dart';
import 'package:medical_app/features/doctor_dahboard/overview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String doctorId = "79ee85c5-c5da-41f5-b4a0-579f4792f32f";
    return DashboardScreen(doctorId: doctorId);
  }
}

class DashboardScreen extends StatefulWidget {
  final String doctorId;

  const DashboardScreen({required this.doctorId, Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isHoveredPatientList = false;
  bool _isHoveredInbox = false;
  bool _isHoveredEarnings = false;
  bool _isHoveredOverview = false;
  bool _isHoveredSchdule = false;
  bool _isHoveredProfile = false;
  int _selectedIndex = 0;

  late Future<Map<String, dynamic>> _doctorData;

  @override
  void initState() {
    super.initState();
    _doctorData = _fetchDoctorData();
  }

  Future<Map<String, dynamic>> _fetchDoctorData() async {
    try {
      final data = await Supabase.instance.client
          .from('doctors')
          .select('first_name, last_name, title, specialty')
          .eq('id', widget.doctorId)
          .maybeSingle();

      return data ?? {
        'first_name': 'Doctor',
        'last_name': '',
        'title': 'Dr.',
        'specialty': 'General Practitioner'
      };
    } catch (e) {
      return {
        'first_name': 'Doctor',
        'last_name': '',
        'title': 'Dr.',
        'specialty': 'General Practitioner'
      };
    }
  }

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
              MaterialPageRoute(builder: (context) => PatientList()),
            );
          } else if (title == "INBOX") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InboxPage()),
            );
          } else if (title == "EARNINGS") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EarningsPage()),
            );
          } else if (title == "OVERVIEW") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OverviewPage()),
            );
          } else if (title == "SCHDULE") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AppointmentSchedulePage()),
            );
          } else if (title == "PROFILE") {
            // Add profile navigation here if needed
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
              drawerItem("EARNINGS", context, _isHoveredEarnings, (hovered) {
                setState(() {
                  _isHoveredEarnings = hovered;
                });
              }),
              drawerItem("OVERVIEW", context, _isHoveredOverview, (hovered) {
                setState(() {
                  _isHoveredOverview = hovered;
                });
              }),
              drawerItem("SCHDULE", context, _isHoveredSchdule, (hovered) {
                setState(() {
                  _isHoveredSchdule = hovered;
                });
              }),
              drawerItem("PROFILE", context, _isHoveredProfile, (hovered) {
                setState(() {
                  _isHoveredProfile = hovered;
                });
              }),
            ],
          ),
        ),
      ),
      body: Container(
        color: AppPallete.secondaryColor,
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _doctorData,
          builder: (context, snapshot) {
            final firstName = snapshot.data?['first_name'] ?? 'Doctor';
            final lastName = snapshot.data?['last_name'] ?? '';
            final title = snapshot.data?['title'] ?? 'Dr.';
            final specialty = snapshot.data?['specialty'] ?? 'General Practitioner';
            final fullName = '$title $firstName $lastName'.trim();

            return Column(
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
                          'Hi ! $firstName',
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
                          fullName,
                          style: TextStyle(
                            fontSize: 33,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.textColor,
                          ),
                        ),
                        Text(
                          specialty,
                          style: TextStyle(
                            fontSize: 23,
                            color: AppPallete.borderColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            );
          },
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

  const BottomNavBar({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: AppPallete.primaryColor,
      unselectedItemColor: AppPallete.greyColor,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ""),
      ],
    );
  }
}