import 'package:flutter/material.dart';
import 'package:medical_app/features/appoinment_history/appoinment.dart';
import 'package:medical_app/features/appoinment_history/cancelled.dart';
import 'package:medical_app/features/appoinment_history/details.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/appoinment_history/upcoming_db.dart';
import 'package:medical_app/features/appoinment_history/appoinment cancelation.dart';

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
  final UpcomingDB _db = UpcomingDB();
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _deletedAppointments = [];
  bool _isLoading = true;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final appointments = await _db.getUpcomingAppointments();
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading appointments: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _deleteAppointment(int index) {
    setState(() {
      _deletedAppointments.add(_appointments[index]);
      _appointments.removeAt(index);
    });
  }

  void _restoreAppointment() {
    setState(() {
      if (_deletedAppointments.isNotEmpty) {
        _appointments.add(_deletedAppointments.last);
        _deletedAppointments.removeLast();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Appointment()),
      );
    } else if (index == 2) {
      // Profile page navigation
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Cancel()),
      );
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
              context,
              MaterialPageRoute(builder: (context) => Appointment()),
            );
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
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
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
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
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
            if (_deletedAppointments.isNotEmpty)
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _appointments.isEmpty
                  ? const Center(
                child: Text(
                  'No upcoming appointments found',
                  style: TextStyle(color: AppPallete.textColor),
                ),
              )
                  : RefreshIndicator(
                onRefresh: _loadAppointments,
                child: ListView.builder(
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = _appointments[index];
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
                                  backgroundImage: appointment['image_url'].startsWith('http')
                                      ? NetworkImage(appointment['image_url'])
                                      : AssetImage(appointment['image_url']) as ImageProvider,
                                  radius: 30,
                                  onBackgroundImageError: (_, __) =>
                                  const Icon(Icons.person, size: 30),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appointment['doctor_name'] ?? 'Unknown Doctor',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppPallete.primaryColor,
                                      ),
                                    ),
                                    Text(appointment['specialty'] ?? 'Unknown Specialty'),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: AppPallete.whiteColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 16, color: AppPallete.primaryColor),
                                      const SizedBox(width: 5),
                                      Text(appointment['date'] ?? 'Unknown date',
                                          style: TextStyle(color: AppPallete.primaryColor)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: AppPallete.whiteColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, size: 16, color: AppPallete.primaryColor),
                                      const SizedBox(width: 5),
                                      Text(appointment['time'] ?? 'Unknown time',
                                          style: TextStyle(color: AppPallete.primaryColor)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AppointmentDetailsPage(
                                          appointmentId: appointment['id'].toString(),
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
                                  child: const Text('Details'),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_circle, color: Colors.green),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CancelAppointmentPage(
                                              appointmentId: _appointments[index]['id'].toString(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: AppPallete.textColor),
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Upcoming'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.cancel), label: 'Cancelled'),
        ],
      ),
    );
  }
}