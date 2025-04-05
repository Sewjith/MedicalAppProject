import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor_dahboard/appoinment_db.dart';

class AppointmentSchedulePage extends StatefulWidget {
  const AppointmentSchedulePage({Key? key}) : super(key: key);

  @override
  State<AppointmentSchedulePage> createState() => _AppointmentSchedulePageState();
}

class _AppointmentSchedulePageState extends State<AppointmentSchedulePage> {
  int _currentIndex = 3;
  final AppointmentDB _db = AppointmentDB();
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  Map<String, dynamic>? _nextAppointment;

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
        _nextAppointment = appointments.isNotEmpty ? appointments[0] : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load appointments: ${e.toString()}')),
      );
    }
  }

  Future<void> _refreshAppointments() async {
    setState(() => _isLoading = true);
    await _loadAppointments();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, MMMM d').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getTimeUntilAppointment(String? dateString, String? timeString) {
    if (dateString == null || timeString == null) return 'Starts soon';

    try {
      final date = DateTime.parse(dateString);
      final timeParts = timeString.split(':');
      final appointmentTime = date.add(Duration(
        hours: int.parse(timeParts[0]),
        minutes: int.parse(timeParts[1]),
      ));

      final now = DateTime.now();
      final difference = appointmentTime.difference(now);

      if (difference.isNegative) return 'Started already';
      if (difference.inDays > 0) return 'Starts in ${difference.inDays} days';
      if (difference.inHours > 0) return 'Starts in ${difference.inHours} hours';
      if (difference.inMinutes > 0) return 'Starts in ${difference.inMinutes} minutes';

      return 'Starts now';
    } catch (e) {
      return 'Starts soon';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppPallete.secondaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppPallete.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text(
            'Appointment Schedule',
            style: TextStyle(
              color: AppPallete.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAppointments,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Upcoming Schedule",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.textColor,
                ),
              ),
              const SizedBox(height: 10),
              if (_nextAppointment != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppPallete.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nextAppointment!['patient_name'] ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.whiteColor,
                        ),
                      ),
                      Text(
                        "Age ${_nextAppointment!['patient_age'] ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppPallete.whiteColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${_formatDate(_nextAppointment!['appointment_date'])} • ${_nextAppointment!['appointment_time'] ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppPallete.whiteColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getTimeUntilAppointment(
                              _nextAppointment!['appointment_date'],
                              _nextAppointment!['appointment_time'],
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppPallete.whiteColor,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Implement join call functionality
                            },
                            icon: const Icon(Icons.video_call),
                            label: const Text("Join Call"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPallete.whiteColor,
                              foregroundColor: AppPallete.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                "Upcoming Appointments",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.textColor,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _appointments.isEmpty
                    ? const Center(
                  child: Text(
                    "No upcoming appointments",
                    style: TextStyle(color: AppPallete.textColor),
                  ),
                )
                    : ListView.builder(
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = _appointments[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppPallete.whiteColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppPallete.borderColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment['patient_name'] ?? 'No Name',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppPallete.textColor,
                                ),
                              ),
                              Text(
                                "Age ${appointment['patient_age'] ?? 'N/A'}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppPallete.greyColor,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatDate(appointment['appointment_date']),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppPallete.textColor,
                                ),
                              ),
                              Text(
                                appointment['appointment_time'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppPallete.textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Add your navigation logic here
        },
        selectedItemColor: AppPallete.primaryColor,
        unselectedItemColor: AppPallete.greyColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ""),
        ],
      ),
    );
  }
}