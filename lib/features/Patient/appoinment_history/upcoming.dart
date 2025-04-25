import 'package:flutter/material.dart';
import 'package:medical_app/features/Patient/appoinment_history/appoinment.dart';
import 'package:medical_app/features/Patient/appoinment_history/cancelled.dart';
import 'package:medical_app/features/Patient/appoinment_history/details.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/Patient/appoinment_history/appoinment cancelation.dart';

void main() {
  runApp(const Upcoming());
}

class Upcoming extends StatelessWidget {
  const Upcoming({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UpcomingPage(),
    );
  }
}

class UpcomingPage extends StatefulWidget {
  @override
  _UpcomingPageState createState() => _UpcomingPageState();
}

class _UpcomingPageState extends State<UpcomingPage> {
  int _selectedIndex = 1;

  final List<Map<String, String>> appointments = [
    {
      'name': 'Dr. Olivia Turner, M.D.',
      'specialty': 'Dermato-Endocrinology',
      'date': 'Sunday, 12 June',
      'time': '9:30 AM - 10:00 AM',
      'image': 'assets/images/doc2.jpeg', // Local image path
    },
    {
      'name': 'Dr. Alexander Bennett, Ph.D.',
      'specialty': 'Dermato-Genetics',
      'date': 'Friday, 20 June',
      'time': '2:30 PM - 3:00 PM',
      'image': 'assets/images/doc2.jpeg',
    },
    {
      'name': 'Dr. Sophia Martinez, Ph.D.',
      'specialty': 'Cosmetic Bioengineering',
      'date': 'Tuesday, 15 June',
      'time': '9:30 AM - 10:00 AM',
      'image': 'assets/images/doc3.png',
    },
  ];


  List<Map<String, String>> deletedAppointments = [];


  void _deleteAppointment(int index) {
    setState(() {

      deletedAppointments.add(appointments[index]);
      appointments.removeAt(index);
    });
  }


  void _restoreAppointment() {
    setState(() {
      if (deletedAppointments.isNotEmpty) {
        appointments.add(deletedAppointments.last);
        deletedAppointments.removeLast();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => Appointment()));
    } else if (index == 1) {

    } else if (index == 2) {

    } else if (index == 3) {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppPallete.primaryColor),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Appointment()));
          },
        ),
        title: Text(
          'All Appointment',
          style: TextStyle(color: AppPallete.primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Appointment()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    backgroundColor: _selectedIndex == 0 ? AppPallete.primaryColor : AppPallete.whiteColor,
                    foregroundColor: _selectedIndex == 0 ? AppPallete.whiteColor : AppPallete.primaryColor,
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
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    backgroundColor: _selectedIndex == 1 ? AppPallete.primaryColor : AppPallete.whiteColor,
                    foregroundColor: _selectedIndex == 1 ? AppPallete.whiteColor : AppPallete.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Upcoming',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Cancel()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    backgroundColor: _selectedIndex == 2 ? AppPallete.primaryColor : AppPallete.whiteColor,
                    foregroundColor: _selectedIndex == 2 ? AppPallete.whiteColor : AppPallete.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Cancelled',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),

            if (deletedAppointments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: _restoreAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[50],
                    foregroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Restore Appointment'),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(appointment['image']!),
                                radius: 30,
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appointment['name']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppPallete.primaryColor,
                                    ),
                                  ),
                                  Text(appointment['specialty']!),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: AppPallete.whiteColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: AppPallete.primaryColor),
                                    SizedBox(width: 5),
                                    Text(appointment['date']!, style: TextStyle(color: AppPallete.primaryColor)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: AppPallete.whiteColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time, size: 16, color: AppPallete.primaryColor),
                                    SizedBox(width: 5),
                                    Text(appointment['time']!, style: TextStyle(color: AppPallete.primaryColor)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AppointmentDetailsPage(
                                        doctorName: appointment['name']!,
                                        specialty: appointment['specialty']!,
                                        appointmentDate: appointment['date']!,
                                        appointmentTime: appointment['time']!,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppPallete.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text('Details'),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check_circle, color: Colors.green),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () {
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) => form()));
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: AppPallete.textColor),
                                    onPressed: () => _deleteAppointment(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Upcoming',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cancel),
            label: 'Cancelled',
          ),
        ],
      ),
    );
  }
}