import 'package:flutter/material.dart';
import '../models/doctor_model.dart';

class DoctorInfoScreen extends StatelessWidget {
  final Doctor doctor;

  DoctorInfoScreen({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor Info"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(doctor.profileImage),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              doctor.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              doctor.specialty,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          SizedBox(height: 30),
          Divider(),

          ListTile(
            leading: Icon(Icons.notifications_off),
            title: Text("Mute notifications"),
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text("Contact Number"),
            subtitle: Text(doctor.phoneNumber ?? "Not available"),
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text("Starred messages"),
            onTap: () {}, // Implement later if needed
          ),
          ListTile(
            leading: Icon(Icons.image),
            title: Text("Media, links, and docs"),
            onTap: () {}, // Can link to media gallery if built
          ),
          ListTile(
            leading: Icon(Icons.visibility),
            title: Text("Media visibility"),
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
        ],
      ),
    );
  }
}
