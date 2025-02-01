import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  ////testing

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Container(
            height: 200,
            color: const Color.fromARGB(255, 118, 218, 232),
            child: Center(
              child: Text("Demo!"),
            ),
          ),
        ),
      ),
    );
  }
}
