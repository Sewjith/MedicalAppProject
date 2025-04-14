import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import 'chat_screen.dart';
import 'package:collection/collection.dart';

class DoctorListScreen extends StatefulWidget {
  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {

    final filteredDoctors = doctors.where((doc) {
      final query = _searchQuery.toLowerCase();
      return doc.name.toLowerCase().contains(query) ||
          doc.specialty.toLowerCase().contains(query);
    }).toList();

    final doctorsBySpecialty = groupBy(filteredDoctors, (Doctor doc) => doc.specialty);

    return Scaffold(
      appBar: AppBar(
        title: Text("Doctors", style: TextStyle(color: Colors.blue)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or specialty',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          Expanded(
            child: ListView(
              children: doctorsBySpecialty.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    ...entry.value.map((doctor) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(doctor.profileImage),
                        ),
                        title: Text(
                          doctor.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Icon(Icons.chat, color: Colors.blue),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatScreen(doctor: doctor)),
                          );
                        },
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
