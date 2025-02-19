import 'package:flutter/material.dart';

class AuthDeatils extends StatelessWidget {
  final String hintText;
  const AuthDeatils({super.key, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hintText,
      ),
    );
  }
}
