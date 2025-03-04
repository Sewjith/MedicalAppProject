import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appointment Schedule',
      theme: ThemeData(
        primaryColor: const Color(0xFF2260FF),
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF2260FF),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 14),
        ),
      ),
      home: const AppointmentManagementPage(),
    );
  }
}

class AppointmentManagementPage extends StatefulWidget {
  const AppointmentManagementPage({super.key});

  @override
  _AppointmentManagementPageState createState() =>
      _AppointmentManagementPageState();
}

class _AppointmentManagementPageState extends State<AppointmentManagementPage> {
  DateTime _selectedDate = DateTime.now();
  late Timer _timer;

  final List<Map<String, String>> appointments = [
    {
      'name': 'John Doe',
      'age': '30',
      'description': 'Headache',
      'time': '15:00',
      'date': '2025-03-04'
    },
    {
      'name': 'Jane Smith',
      'age': '25',
      'description': 'Fever',
      'time': '16:30',
      'date': '2025-03-04'
    },
    {
      'name': 'Emma Johnson',
      'age': '28',
      'description': 'Coughing',
      'time': '17:00',
      'date': '2025-03-05'
    },
    {
      'name': 'David Lee',
      'age': '35',
      'description': 'Back Pain',
      'time': '18:00',
      'date': '2025-03-06'
    },
    {
      'name': 'Sarah Brown',
      'age': '40',
      'description': 'Stomach Ache',
      'time': '19:00',
      'date': '2025-03-06'
    },
    {
      'name': 'Michael Davis',
      'age': '50',
      'description': 'High Blood Pressure',
      'time': '20:00',
      'date': '2025-03-06'
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  List<Map<String, String>> getFilteredAppointments(DateTime selectedDate) {
    return appointments.where((appointment) {
      DateTime appointmentDate =
          DateFormat('yyyy-MM-dd').parse(appointment['date']!);
      return appointmentDate.isAtSameMomentAs(selectedDate);
    }).toList();
  }

  String _getRemainingTime(String appointmentTime, String appointmentDate) {
    DateTime now = DateTime.now();

    DateTime appointmentDateTime = DateFormat('yyyy-MM-dd HH:mm')
        .parse('$appointmentDate $appointmentTime');

    if (appointmentDateTime.isBefore(now)) {
      return "Started";
    }

    Duration remaining = appointmentDateTime.difference(now);

    int days = remaining.inDays;
    int hours = remaining.inHours % 24;
    int minutes = remaining.inMinutes % 60;
    int seconds = remaining.inSeconds % 60;

    return "${days.toString().padLeft(2, '0')}:${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _showStartStreamConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Start Stream"),
        content: const Text(
            "Are you sure you want to start the stream for this appointment?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle stream start logic here
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetailsDialog(
      BuildContext context, Map<String, String> appointment) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: Colors.black.withOpacity(0),
                  ),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Patient: ${appointment['name']}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Age: ${appointment['age']} | Description: ${appointment['description']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Appointment Time: ${appointment['time']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _showStartStreamConfirmationDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2260FF),
                        ),
                        child: const Text(
                          'Start Consultation Stream',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredAppointments =
        getFilteredAppointments(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Schedule'),
        backgroundColor: const Color(0xFF2260FF),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Appointments for ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                  ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredAppointments.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredAppointments.length,
                      itemBuilder: (context, index) {
                        var appointment = filteredAppointments[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.lightBlue[50],
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF2260FF),
                              child: Text(
                                appointment['name']![0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(appointment['name']!),
                            subtitle: Text(
                              'Age: ${appointment['age']} | ${appointment['description']}\nTime: ${appointment['time']} | ${_getRemainingTime(appointment['time']!, appointment['date']!)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              _showAppointmentDetailsDialog(
                                  context, appointment);
                            },
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'No Appointments for This Day',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
