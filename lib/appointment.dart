import 'package:flutter/material.dart';

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2260FF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilterOptions(),
          Expanded(child: _buildAppointmentList(context)),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFCAD6FF),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DropdownButton<String>(
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              items: <String>['All', 'Upcoming', 'Past'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {}, // Add filter logic here
              hint: const Text('Filter by'),
            ),
            ElevatedButton(
              onPressed: () {
                // Refresh logic can go here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2260FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(BuildContext context) {
    List<Map<String, String>> appointments = List.generate(10, (index) {
      return {
        'title': 'Dentist Appointment $index',
        'category': 'Appointment',
        'addedDate': 'Feb 10, 2024',
        'description': 'Regular check-up and cleaning.',
        'location': 'Health Clinic, Main Street',
        'status': 'Upcoming',
      };
    });

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: const Color(0xFFCAD6FF),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: const Icon(Icons.calendar_today,
                    size: 32, color: Colors.black54),
              ),
              title: Text(
                appointments[index]['title']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Reduced font size
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category: ${appointments[index]['category']}',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12, // Reduced font size
                    ),
                  ),
                  Text(
                    'Added Date: ${appointments[index]['addedDate']}',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12, // Reduced font size
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.red),
                    onPressed: () {
                      // Handle like button press
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black54),
                    onPressed: () {
                      _showDeleteConfirmation(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline,
                        color: Colors.blueAccent),
                    onPressed: () {
                      _showDownloadOrViewOptions(
                          context, appointments[index]); // Info Icon Click
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Do you want to delete this appointment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle delete logic here
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2260FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showDownloadOrViewOptions(
      BuildContext context, Map<String, String> appointment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose an Option'),
          content: Text(
              'Do you want to download or view the appointment: "${appointment['title']}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _viewAppointment(context, appointment); // View appointment
              },
              child: const Text('View'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadAppointmentDetails(
                    appointment); // Download appointment
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2260FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Download'),
            ),
          ],
        );
      },
    );
  }

  void _viewAppointment(BuildContext context, Map<String, String> appointment) {
    // Navigate to the appointment detail page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentDetailPage(appointment: appointment),
      ),
    );
  }

  void _downloadAppointmentDetails(Map<String, String> appointment) {
    // Simulate downloading the appointment details (e.g., print the details)
    print(
        "Downloading appointment: ${appointment['title']}..."); // Replace with actual download logic
  }
}

class AppointmentDetailPage extends StatelessWidget {
  final Map<String, String> appointment;

  const AppointmentDetailPage({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: const Color(0xFF2260FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${appointment['title']}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(height: 8),
            Text('Description: ${appointment['description']}'),
            SizedBox(height: 8),
            Text('Location: ${appointment['location']}'),
            SizedBox(height: 8),
            Text('Added Date: Feb 10, 2024'),
            SizedBox(height: 8),
            Text('Status: ${appointment['status']}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2260FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
