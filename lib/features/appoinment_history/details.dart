import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/appoinment_history/details_db.dart';
import 'package:medical_app/features/appoinment_history/appoinment cancelation.dart';
class AppointmentDetailsPage extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailsPage({Key? key, required this.appointmentId}) : super(key: key);

  @override
  _AppointmentDetailsPageState createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  final AppointmentDetailsDB _db = AppointmentDetailsDB();
  late Future<Map<String, dynamic>> _appointmentDetails;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _appointmentDetails = _db.getAppointmentDetails(widget.appointmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.whiteColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppPallete.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Appointment Details',
          style: TextStyle(color: AppPallete.primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _appointmentDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No appointment found'));
          }

          final details = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: details['doctor_image'] != null
                              ? NetworkImage(details['doctor_image'])
                              : AssetImage('assets/images/default_doctor.png') as ImageProvider,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                details['doctor_name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                details['specialty'],
                                style: TextStyle(color: AppPallete.greyColor),
                              ),
                              SizedBox(height: 4),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Appointment Details Section
                Text(
                  'Appointment Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.primaryColor,
                  ),
                ),
                Divider(),
                SizedBox(height: 10),
                _buildDetailItem('Appointment ID', details['appointment_id']),
                _buildDetailItem('Patient Name', details['patient_name']),
                _buildDetailItem('Date', details['appointment_date']),
                _buildDetailItem('Time', details['appointment_time']),
                _buildDetailItem('Status', details['status']),
                SizedBox(height: 15),

                // Qualifications Section
                Text(
                  'Doctor Qualifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppPallete.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('• ${details['qualifications']}'),
                ),
                SizedBox(height: 20),

                // Notes Section
                Text(
                  'Additional Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppPallete.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(details['notes']),
                ),

              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        // Add navigation logic here
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppPallete.primaryColor,
      unselectedItemColor: AppPallete.greyColor,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}