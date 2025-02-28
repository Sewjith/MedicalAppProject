import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appointment_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Appointment Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
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
      'date': '2025-02-21'
    },
    {
      'name': 'Jane Smith',
      'age': '25',
      'description': 'Fever',
      'time': '16:30',
      'date': '2025-02-21'
    },
    {
      'name': 'Emma Johnson',
      'age': '28',
      'description': 'Coughing',
      'time': '17:00',
      'date': '2025-02-22'
    },
    {
      'name': 'David Lee',
      'age': '35',
      'description': 'Back Pain',
      'time': '18:00',
      'date': '2025-02-23'
    },
    {
      'name': 'Sarah Brown',
      'age': '40',
      'description': 'Stomach Ache',
      'time': '19:00',
      'date': '2025-02-24'
    },
    {
      'name': 'Michael Davis',
      'age': '50',
      'description': 'High Blood Pressure',
      'time': '20:00',
      'date': '2025-02-24'
    },
  ];

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

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

  List<Map<String, String>> getFilteredAppointments() {
    return appointments.where((appointment) {
      DateTime appointmentDate =
          DateFormat('yyyy-MM-dd').parse(appointment['date']!);
      return appointmentDate.isAtSameMomentAs(_selectedDate);
    }).toList();
  }

  String _getRemainingTime(String appointmentTime) {
    DateTime now = DateTime.now();
    DateTime appointmentDateTime = DateFormat('HH:mm').parse(appointmentTime);
    appointmentDateTime = DateTime(now.year, now.month, now.day,
        appointmentDateTime.hour, appointmentDateTime.minute);

    if (appointmentDateTime.isBefore(now)) {
      return "Started";
    }

    Duration remaining = appointmentDateTime.difference(now);
    int minutes = remaining.inMinutes;

    // Check if it's within 10 minutes before the appointment
    if (minutes == 10) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTimeAlertDialog(context, appointmentTime);
      });
    }

    int hours = remaining.inHours;
    minutes = remaining.inMinutes % 60;
    int seconds = remaining.inSeconds % 60;

    return "$hours h $minutes m $seconds s remaining";
  }

  void _showTimeAlertDialog(BuildContext context, String appointmentTime) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("10 Minutes Left!"),
        content: Text(
            "The appointment at $appointmentTime is about to start in 10 minutes."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentViewPage(
          startDate: _startDate,
          endDate: _endDate,
          appointments: appointments,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredAppointments = getFilteredAppointments();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date Range Selection Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Date Range:',
                    style: Theme.of(context).textTheme.bodyLarge),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.blue),
                  onPressed: () => _showDateRangePicker(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Date Picker
            CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date; // Update the selected date
                });
              },
            ),
            const SizedBox(height: 16),

            // Display Appointments for Selected Date
            Text(
              'Appointments for ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),

            // List of Filtered Appointments
            Expanded(
              child: filteredAppointments.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredAppointments.length,
                      itemBuilder: (context, index) {
                        var appointment = filteredAppointments[index];
                        return Card(
                          color: const Color(0xFFCAD6FF),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF2260FF),
                              child: Text(
                                appointment['name']![0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(appointment['name']!),
                            subtitle: Text(
                              '${appointment['age']} years old\n${appointment['description']}\nRemaining: ${_getRemainingTime(appointment['time']!)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            onTap: () {
                              _showStartStreamDialog(context);
                            },
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'No Appointments for Selected Date',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartStreamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Start Streaming"),
        content: const Text("Do you want to start the stream?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2260FF),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Start Stream",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
