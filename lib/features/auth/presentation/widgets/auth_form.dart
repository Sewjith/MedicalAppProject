import 'package:flutter/material.dart';

class AuthDetails extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isPassword;
  final Widget? suffixIcon; // Optional

  const AuthDetails({
    super.key,
    required this.hintText,
    required this.controller,
    this.validator,
    this.isPassword = false,
    this.suffixIcon,
  });

  @override
  State<AuthDetails> createState() => _AuthDetailsState();
}

class _AuthDetailsState extends State<AuthDetails> {
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    isPasswordVisible =
        widget.isPassword; // Initially hide text if it's a password field
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && !isPasswordVisible,
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              )
            : widget.suffixIcon, // Use provided suffixIcon if available
      ),
    );
  }
}
