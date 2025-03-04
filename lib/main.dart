import 'package:flutter/material.dart';
import 'package:flutter_application_1/medicalHistory.dart';
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
        primaryColor: const Color(0xFF2260FF),
        scaffoldBackgroundColor: Colors.white,
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
        title: const Text('Digital Health Records',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2260FF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recently Added Reports:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFFCAD6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildReportCard(context, index);
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select a category:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: 7,
                itemBuilder: (context, index) {
                  return _buildCategoryTile(context, index);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReportPage()),
          );
        },
        backgroundColor: const Color(0xFF2260FF),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFCAD6FF),
            child: const Icon(Icons.picture_as_pdf,
                size: 30, color: Colors.black87),
          ),
          title: const Text('Blood Test Report - Jan 2024'),
          subtitle: const Text('Category: Blood Test'),
          trailing:
              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        List<Widget> pages = [
          const MedicalHistoryPage(),
          const AppointmentPage(),
          const LabResultPage(),
          const VaccinationsPage(),
          const EmergencyPage(),
          const DentalVisionPage(),
          const AddReportPage(),
        ];
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => pages[index]),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 46, 163),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getMenuIcon(index),
            const SizedBox(height: 8),
            Text(
              _getMenuTitle(index),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _getMenuTitle(int index) {
    return [
      'Medical History',
      'Appointments',
      'Lab Results',
      'Vaccinations',
      'Emergency',
      'Dental & Vision',
      'Add Report'
    ][index];
  }

  Icon _getMenuIcon(int index) {
    List<IconData> icons = [
      Icons.history,
      Icons.calendar_today,
      Icons.note,
      Icons.local_hospital,
      Icons.emergency,
      Icons.visibility,
      Icons.upload_file,
    ];
    return Icon(icons[index], color: Colors.white, size: 40);
  }
}
