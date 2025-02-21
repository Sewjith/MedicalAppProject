import 'package:flutter/material.dart';

class AuthDetails extends StatelessWidget {
  final String hintText;
  const AuthDetails({super.key, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
      ),
    );
  }
}
