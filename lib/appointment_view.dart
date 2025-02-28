import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentViewPage extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final List<Map<String, String>> appointments;

  const AppointmentViewPage({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.appointments,
  }) : super(key: key);

  List<Map<String, String>> getFilteredAppointments() {
    return appointments.where((appointment) {
      DateTime appointmentDate =
          DateFormat('yyyy-MM-dd').parse(appointment['date']!);
      return appointmentDate.isAfter(startDate.subtract(Duration(days: 1))) &&
          appointmentDate.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredAppointments = getFilteredAppointments();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtered Appointments'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        '${appointment['age']} years old\n${appointment['description']}\nTime: ${appointment['time']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: Text('No Appointments for Selected Date Range',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
              ),
      ),
    );
  }
}
