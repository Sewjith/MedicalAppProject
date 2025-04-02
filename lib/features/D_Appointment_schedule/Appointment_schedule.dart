import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'A_schedule_backend.dart';

class AppointmentManagementPage extends StatefulWidget {
  const AppointmentManagementPage({super.key});

  @override
  State<AppointmentManagementPage> createState() =>
      _AppointmentManagementPageState();
}

class _AppointmentManagementPageState extends State<AppointmentManagementPage> {
  DateTime _selectedDate = DateTime.now();
  late AppointmentService _appointmentService;
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final String doctorId = '9968ff7d-9319-4fba-8104-7b5a6bc6f3db';

  @override
  void initState() {
    super.initState();
    _appointmentService = AppointmentService(Supabase.instance.client);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final appointments = await _appointmentService.getDoctorAppointments(
        doctorId,
        _selectedDate,
      );

      if (!mounted) return;

      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Failed to load appointments: ${e.toString()}';
        _isLoading = false;
        _appointments = [];
      });
      debugPrint('Error loading appointments: $e');
    }
  }

  DateTime _parseAppointmentDateTime(String dateTimeStr) {
    try {
      return DateTime.parse(dateTimeStr);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return DateTime.now(); 
    }
  }

  Color _getCardColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green.shade100;
      case 'Pending':
        return Colors.orange.shade100;
      case 'Cancelled':
        return Colors.red.shade100;
      default:
        return Colors.blue.shade100;
    }
  }

  String _getRemainingTime(DateTime appointmentDateTime) {
    final now = DateTime.now();
    final difference = appointmentDateTime.difference(now);
    if (difference.isNegative) {
      return 'Appointment missed';
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return '$hours hours and $minutes minutes remaining';
    }
  }

  void _showAppointmentDetailsDialog(
      BuildContext context, Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Appointment Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Patient Name: ${appointment['patient_name'] ?? 'N/A'}'),
              Text('Age: ${appointment['patient_age'] ?? 'N/A'}'),
              Text('Gender: ${appointment['patient_gender'] ?? 'N/A'}'),
              Text('Status: ${appointment['status'] ?? 'N/A'}'),
              Text('Notes: ${appointment['notes'] ?? 'N/A'}'),
              Text(
                  'Appointment Time: ${appointment['appointment_time'] ?? 'N/A'}'),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                _startStreamConfirmation(context);
              },
              child: const Text('Start Stream'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _startStreamConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to start the stream?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                _loadAppointments(); 
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
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _appointments.isEmpty
                      ? const Center(
                          child: Text(
                            'No Appointments for This Day',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = _appointments[index];
                            final appointmentDateTime =
                                _parseAppointmentDateTime(
                                    appointment['appointment_datetime']);
                            final appointmentTime =
                                appointment['appointment_time'] ??
                                    'Not mentioned';

                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              color: _getCardColor(appointment['status']),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF2260FF),
                                  child: Text(
                                    appointment['patient_name'] != null
                                        ? appointment['patient_name'][0]
                                        : '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                    appointment['patient_name'] ?? 'No name'),
                                subtitle: Text(
                                  'Age: ${appointment['patient_age'] ?? 'Not mentioned'} | ${appointment['status'] ?? 'Status unknown'}\nTime: $appointmentTime | ${_getRemainingTime(appointmentDateTime)}',
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
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
