import 'package:flutter/material.dart';
import 'package:medical_app/features/auth/presentation/widgets/auth_form.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Login',
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
          ),
          AuthDeatils(hintText: 'Email'),
          AuthDeatils(hintText: 'Password'),
        ],
      ),
    );
  }
}
