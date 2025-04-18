import 'package:flutter/material.dart';
import 'package:medical_app/screens/notifications_screen.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // TODO: Replace these with real values if using login later
  final String receiverId = 'abc-123'; // This could be a patient or doctor ID
  final String receiverType = 'patient'; // or 'doctor'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationsScreen(
        receiverId: receiverId,
        receiverType: receiverType,
      ),
    );
  }
}
