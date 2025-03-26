import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/bottom_nav_bar.dart';

import 'package:flutter/material.dart';

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
    String doctorId = '79ee85c5-c5da-41f5-b4a0-579f4792f32f';

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
        final doctorId = '79ee85c5-c5da-41f5-b4a0-579f4792f32f';
        context.go('/doctor-earning/$doctorId');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: widget.child),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex, // Pass selected index
        onItemTapped: _onItemTapped, // Pass onTap callback
      ),
    );
  }
}
