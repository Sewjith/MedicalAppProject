import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/auth/presentation/widgets/auth_form.dart';
import 'package:go_router/go_router.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BackButton(
                  onPressed: () {
                    context.go('/login');
                  },
                ),
                const SizedBox(
                  width: 70,
                ),
                const Text(
                  'Forgot Password',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.headings),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(35.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                      'Video provides a powerful way to help you prove your point. When you click Online Video.'),
                  const SizedBox(height: 30),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Enter Password',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.textColor),
                      )),
                  const SizedBox(height: 15),
                  const AuthDetails(hintText: '********************'),
                  const SizedBox(height: 15),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Confirm Password',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.textColor),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const AuthDetails(hintText: '********************'),
                  const SizedBox(height: 30,),
                  FilledButton(
                    onPressed: () {
                      context.go('/home');
                    },
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.blueAccent),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 80, vertical: 10))
                    ),
                    child: const Text(
                      'Reset Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                      ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
