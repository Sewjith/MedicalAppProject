import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/bottom_nav_bar.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0; // To track the current selected index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home'); // Navigate to Home
        break;
      case 1:
        context.go('/login'); // Navigate to Chat
        break;
      case 2:
        context.go('/doctor-profiles'); // Navigate to Profile
        break;
      case 3:
        context.go('/d-appointment_schedule'); // Navigate to Calendar
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Taskbar'),
      // ),
      body: SafeArea(child: widget.child),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex, // Pass selected index
        onItemTapped: _onItemTapped, // Pass onTap callback
      ),
    );
  }
}
