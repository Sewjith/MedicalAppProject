import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'consultation_page.dart'; 
import 'package:medical_app/features/main_features/teleconsultation/Domain/config.dart';


class IndexPage extends StatefulWidget {
  final String? appointmentId;

  const IndexPage({Key? key, this.appointmentId}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final TextEditingController _channelController = TextEditingController();

  final String appId = "";

  @override
  void initState() {
    super.initState();
    if (widget.appointmentId != null) {
      _channelController.text = widget.appointmentId!;
    }
  }

  // Function to fetch token from the server
  Future<String> fetchToken(String appointmentId, String uid) async {
    final response = await http.get(
      Uri.parse('${AppConfig.serverUrl}/get-token?appointmentId=$appointmentId&uid=$uid'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to fetch token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teleconsultation")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _channelController,
              decoration: InputDecoration(
                labelText: "Enter Channel Name (Appointment ID)",
                labelStyle: const TextStyle(fontSize: 18),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (_channelController.text.isNotEmpty) {
                    try {
                      String appointmentId = _channelController.text;
                      String uid = '12345'; // Set user ID here

                      // Show loading spinner
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      String token = await fetchToken(appointmentId, uid);

                      // Close loading spinner
                      Navigator.of(context).pop();

                      // Navigate to consultation page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorConsultation(
                            appId: appId,
                            token: token,
                            channelName: appointmentId,
                          ),
                        ),
                      );
                    } catch (e) {
                      Navigator.of(context).pop(); // Close spinner
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to generate token")),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a channel name")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text("Start Video Call"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
