import 'package:flutter/material.dart';
import 'medicalHistory.dart';
import 'add_report.dart';
import 'dental_vision.dart';
import 'emergency.dart';
import 'lab_result.dart';
import 'vaccinations.dart';
import 'appointment.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Health Records',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Health Records'),
        backgroundColor: const Color(0xFF2260FF), // light blue color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Recently Added Reports" section
              const Text(
                'Recently Added Reports:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Scrollable container for Recently Added Reports
              Container(
                height: 300, // Fixed height for scrolling
                child: ListView.builder(
                  itemCount: 4, // Display 4 reports
                  itemBuilder: (context, index) {
                    return _buildReportCard(context, index);
                  },
                ),
              ),

              const SizedBox(height: 20),

              // "Select the tile as you wish to enter data"
              const Text(
                'Select the tile you wish to view data:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Tile menu for different pages
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemCount: 7, // Updated to 7 items
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      // Navigate to the relevant page
                      switch (index) {
                        case 0:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const MedicalHistoryPage()),
                          );
                          break;
                        case 1:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AppointmentPage()),
                          );
                          break;
                        case 2:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LabResultPage()),
                          );
                          break;
                        case 3:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const VaccinationsPage()),
                          );
                          break;
                        case 4:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EmergencyPage()),
                          );
                          break;
                        case 5:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DentalVisionPage()),
                          );
                          break;
                        case 6:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddReportPage()),
                          );
                          break;
                      }
                    },
                    child: Card(
                      color: const Color(0xFF2260FF),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _getMenuIcon(index),
                          const SizedBox(height: 8),
                          Text(
                            _getMenuTitle(index),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // FloatingActionButton to navigate to Add Report page
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReportPage()),
          );
        },
        backgroundColor: const Color(0xFF2260FF),
        child: const Icon(Icons.add, size: 30), // Plus icon
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.picture_as_pdf, size: 30),
          ),
          title: const Text('Blood Test Report - Jan 2024'),
          subtitle: const Text('Category: Blood Test'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // Handle like button press
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmation(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  _showReportDetails(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Do you want to delete this report?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                // Handle delete logic here
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showReportDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Title: Blood Test Report - Jan 2024'),
              Text('Description: Routine blood test for health check-up.'),
              Text('Date: Jan 15, 2024'),
              Text('Category: Blood Test'),
              Text('Status: Completed'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _getMenuTitle(int index) {
    switch (index) {
      case 0:
        return 'Medical History';
      case 1:
        return 'Appointments';
      case 2:
        return 'Lab Results';
      case 3:
        return 'Vaccinations';
      case 4:
        return 'Emergency Data';
      case 5:
        return 'Dental & Vision';
      case 6:
        return 'Add Report';
      default:
        return '';
    }
  }

  Icon _getMenuIcon(int index) {
    switch (index) {
      case 0:
        return const Icon(Icons.history, color: Colors.white, size: 40);
      case 1:
        return const Icon(Icons.calendar_today, color: Colors.white, size: 40);
      case 2:
        return const Icon(Icons.note, color: Colors.white, size: 40);
      case 3:
        return const Icon(Icons.local_hospital, color: Colors.white, size: 40);
      case 4:
        return const Icon(Icons.emergency, color: Colors.white, size: 40);
      case 5:
        return const Icon(Icons.visibility, color: Colors.white, size: 40);
      case 6:
        return const Icon(Icons.upload_file, color: Colors.white, size: 40);
      default:
        return const Icon(Icons.help, color: Colors.white, size: 40);
    }
  }
}
