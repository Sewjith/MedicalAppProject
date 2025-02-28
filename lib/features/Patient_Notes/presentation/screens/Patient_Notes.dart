import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientNotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PatientManagementScreen(),
    );
  }
}

class PatientManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.black),
        title: Text("Patient Notes", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Icon(Icons.notifications, color: Colors.black),
          SizedBox(width: 15),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            SizedBox(height: 20),
            _buildSectionTitle("Medical History"),
            _buildInfoCard("Allergies", "N/A"),
            _buildInfoCard("Medications", "N/A"),
            _buildInfoCard("Past Surgeries", "N/A"),
            SizedBox(height: 20),
            _buildSectionTitle("Consultation Notes"),
            Expanded(child: _buildConsultationNotes()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(radius: 30, backgroundImage: AssetImage('assets/profile.jpg')),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Patient Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Age: N/A", style: TextStyle(color: Colors.grey)),
            Text("Gender: N/A", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildConsultationNotes() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            leading: CircleAvatar(backgroundImage: AssetImage('assets/doctor.jpg')),
            title: Text("Dr. Example", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Date: N/A"),
                Text("Notes: No notes available"),
              ],
            ),
          ),
        );
      },
    );
  }
}
