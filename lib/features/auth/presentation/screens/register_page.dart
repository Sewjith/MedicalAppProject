import 'package:medical_app/features/auth/presentation/widgets/auth_form.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Register',
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
          ),
          AuthDeatils(hintText: 'Name'),
          AuthDeatils(hintText: 'Email'),
          AuthDeatils(hintText: 'Password'),
          AuthDeatils(hintText: 'Confirm Password'),
        ],
      ),
    );
  }
}
