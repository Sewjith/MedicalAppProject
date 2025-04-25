import 'package:flutter/material.dart';
import 'dart:async';
import 'package:medical_app/core/themes/app_themes.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/main_features/Emergency_Assistance/connecting_doc.dart';

class EmergencyAssistantPage extends StatefulWidget {
  @override
  _EmergencyAssistantPageState createState() => _EmergencyAssistantPageState();
}

class _EmergencyAssistantPageState extends State<EmergencyAssistantPage>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late AnimationController _controller;
  int _selectedIndex = 0;  // For the Bottom Navigation Bar

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
      lowerBound: 1.0,
      upperBound: 1.2,
    )..repeat(reverse: true);

    _controller.addListener(() {
      setState(() {
        _scale = _controller.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEmergencyPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConnectingDocPage()),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.primaryColor, // Blue background
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Emergency Assistant",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppPallete.whiteColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              // Text similar to Overview Page
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              SizedBox(height: 30), // Increased space to move elements down
              // Main Text: Do you have an emergency
              Center(
                child: Text(
                  "Do you have an Emergency?",
                  style: TextStyle(
                    fontSize: 40,  // Increased font size
                    fontWeight: FontWeight.bold,  // Bold text
                  ),
                ),
              ),
              SizedBox(height: 60), // Increased space between text and button
              // Animated Button
              GestureDetector(
                onTap: _onEmergencyPressed,
                child: Transform.scale(
                  scale: _scale,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(40),
                    child: Text(
                      "Yes",
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
class EmergencyRequestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Emergency Request")),
      body: Center(child: Text("This is the new page!")), // Replace with your actual content
    );
  }
}
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  BottomNavBar({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: AppPallete.primaryColor,
      unselectedItemColor: AppPallete.greyColor,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "", // Empty label (icon only)
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: "", // Empty label (icon only)
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "", // Empty label (icon only)
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "", // Empty label (icon only)
        ),
      ],
    );
  }
}

