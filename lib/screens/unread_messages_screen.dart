import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import 'doctor_chat_screen.dart';

class UnreadMessagesScreen extends StatefulWidget {
  const UnreadMessagesScreen({super.key});

  @override
  State<UnreadMessagesScreen> createState() => _UnreadMessagesScreenState();
}

class _UnreadMessagesScreenState extends State<UnreadMessagesScreen> {
  final List<Patient> unreadPatients = [
    Patient(name: "Alice Johnson", condition: "Diabetes", profileImage: "", isRead: false),
    Patient(name: "Bob Smith", condition: "Asthma", profileImage: "", isRead: false),
    Patient(name: "Charlie Rose", condition: "High BP", profileImage: "", isRead: false),
    Patient(name: "Diana Prince", condition: "Migraines", profileImage: "", isRead: false),
    Patient(name: "Ethan Hunt", condition: "Allergies", profileImage: "", isRead: false),
  ];

  void _markAsReadAndNavigate(Patient patient) {
    setState(() {
      patient.isRead = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorChatScreen(patient: patient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unread Messages"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: unreadPatients.length,
        itemBuilder: (context, index) {
          final patient = unreadPatients[index];

          return ListTile(
            leading: CircleAvatar(
              child: Text(patient.name[0]),
              backgroundColor: Colors.red[200],
            ),
            title: Text(patient.name),
            subtitle: Text(patient.isRead ? "Read" : "Unread message..."),
            trailing: patient.isRead
                ? null
                : const Icon(Icons.mark_chat_unread, color: Colors.red),
            onTap: () => _markAsReadAndNavigate(patient),
          );
        },
      ),
    );
  }
}
