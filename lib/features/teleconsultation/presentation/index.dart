import 'package:flutter/material.dart';
import 'consultation_page.dart'; // Import the video call page

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final TextEditingController _channelController = TextEditingController();

  // Securely retrieve and store credentials
  final String appId = "";
  final String token =
      "";

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
                labelText: "Enter Channel Name",
                labelStyle: const TextStyle(fontSize: 18),
                border: OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                
              ),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200, // Increases button width for better UX
              height: 50, // Increases button height for better UX
              child: ElevatedButton(
                onPressed: () {
                  if (_channelController.text.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorConsultation(
                          appId: appId,
                          token: token,
                          channelName: _channelController.text,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a channel name")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 18), // Bigger text
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), 
                  // Rounded corners
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
