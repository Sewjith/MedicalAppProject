import 'package:flutter/material.dart';

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
        body: Center(
          child: Container(
            height: 200,
            color: const Color.fromARGB(255, 118, 218, 232),
            child: Center(child: Text("Demo!")),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex, // Current selected index
          onTap: _onItemTapped, // Handle item tap
          selectedItemColor: Colors.blue, // Change color when selected
          unselectedItemColor: Colors.grey[700], // Change color when unselected
          type: BottomNavigationBarType.fixed, // Fixed navigation bar, no animation
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
        ),
      ),
    );
  }
}
