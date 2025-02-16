import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0; // To track the current selected index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Demo!')),
        
        bottomNavigationBar: BottomNavBar(
          selectedIndex: _selectedIndex, // Pass selected index
          onItemTapped: _onItemTapped, // Pass onTap callback
        ),
      ),
    );
  }
}
