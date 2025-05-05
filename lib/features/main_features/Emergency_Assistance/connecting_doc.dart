import 'package:flutter/material.dart';
import 'dart:async';
class ConnectingDocPage extends StatefulWidget {
  @override
  _ConnectingDocPageState createState() => _ConnectingDocPageState();
}

class _ConnectingDocPageState extends State<ConnectingDocPage> {
  bool isConnectingVideoCall = false;
  bool isConnectingCall = false;
  bool isViewingDoctorProfile = false;
  bool isMicActive = false;
  bool isRecordingAudio = false;
  double recordingProgress = 0.0;
  int dotCount = 0;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount + 1) % 4;
      });
    });
  }

  // Function to handle item tap on the BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index; // Update selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor Connection"),
      ),
      body: SingleChildScrollView( // Wrap body in SingleChildScrollView
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Center(
              child: Text(
                'Connecting to a Doctor${'.' * dotCount}',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 80),
            DoctorCallButtons(
              onVideoCallPressed: _onVideoCallPressed,
              onCallPressed: _onCallPressed,
              onViewPressed: _onViewPressed,
              onMicPressed: _onMicPressed,
              isMicActive: isMicActive,
              isRecordingAudio: isRecordingAudio,
            ),
            if (isConnectingVideoCall) _buildConnectingScreen('Connecting to Video Call...'),
            if (isConnectingCall) _buildConnectingScreen('Connecting to Call...'),
            if (isViewingDoctorProfile) _buildConnectingScreen("Viewing Doctor's Profile..."),
            if (isRecordingAudio) _buildRecordingStatus(), // Display recording status
            if (isRecordingAudio) _buildRecordingProgress(), // Display progress line while recording
          ],
        ),
      ),
    );
  }

  void _onVideoCallPressed() {
    setState(() => isConnectingVideoCall = true);
    Future.delayed(Duration(seconds: 3), () => setState(() => isConnectingVideoCall = false));
  }

  void _onCallPressed() {
    setState(() => isConnectingCall = true);
    Future.delayed(Duration(seconds: 3), () => setState(() => isConnectingCall = false));
  }

  void _onViewPressed() {
    setState(() => isViewingDoctorProfile = true);
    Future.delayed(Duration(seconds: 3), () => setState(() => isViewingDoctorProfile = false));
  }

  void _onMicPressed() {
    setState(() {
      isMicActive = !isMicActive;
      if (isMicActive) {
        isRecordingAudio = true; // Start recording
        recordingProgress = 0.0; // Reset progress
        _startRecording(); // Start recording progress update
      } else {
        isRecordingAudio = false; // Stop recording
        recordingProgress = 0.0; // Reset progress
      }
    });
  }

  // Function to simulate recording progress
  void _startRecording() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (isRecordingAudio) {
        setState(() {
          recordingProgress += 0.01; // Increment the progress
          if (recordingProgress >= 1.0) {
            recordingProgress = 1.0;
            timer.cancel(); // Stop updating when progress reaches 100%
          }
        });
      } else {
        timer.cancel(); // Stop updating progress if recording is stopped
      }
    });
  }

  Widget _buildConnectingScreen(String message) {
    return Positioned(
      bottom: 40,
      right: 40,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // Widget to show recording status when mic is active
  Widget _buildRecordingStatus() {
    return Positioned(
      bottom: 100,
      left: 20,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          'Recording Audio...',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget to show the recording progress (green line)
  Widget _buildRecordingProgress() {
    return Positioned(
      bottom: 140,
      left: 20,
      right: 20,
      child: Container(
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: recordingProgress, // Use the progress to fill the bar
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green, // Green color for progress
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }
}

class DoctorCallButtons extends StatelessWidget {
  final VoidCallback onVideoCallPressed;
  final VoidCallback onCallPressed;
  final VoidCallback onViewPressed;
  final VoidCallback onMicPressed;
  final bool isMicActive;
  final bool isRecordingAudio;

  const DoctorCallButtons({
    required this.onVideoCallPressed,
    required this.onCallPressed,
    required this.onViewPressed,
    required this.onMicPressed,
    required this.isMicActive,
    required this.isRecordingAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton(Icons.call, Colors.green, onCallPressed),
            _buildButton(Icons.videocam, Colors.purple, onVideoCallPressed),
          ],
        ),
        SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton(Icons.remove_red_eye, Colors.blue, onViewPressed),
            _buildMicButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(15),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: onMicPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isRecordingAudio ? Colors.red : Colors.blue, // Change color when recording
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(20), // Increase padding for consistency
        child: Icon(
          isRecordingAudio ? Icons.stop : Icons.mic, // Change icon to stop if recording
          color: Colors.white,
          size: 50, // Keep the icon size consistent with others
        ),
      ),
    );
  }
}