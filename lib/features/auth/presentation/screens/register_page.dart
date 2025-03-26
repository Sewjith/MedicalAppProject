import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/auth/presentation/widgets/auth_form.dart';
import 'package:go_router/go_router.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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
                  width: 65,
                ),
                const Text(
                  'Register',
                  style: TextStyle(
                      fontSize: 50,
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
                  Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Full Name or Email ',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.textColor),
                      )),
                  const SizedBox(height: 10),
                  const AuthDetails(hintText: 'example@example.com'),
                  const SizedBox(height: 10),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Enter Password',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.textColor),
                      )),
                  const SizedBox(height: 10),
                  const AuthDetails(hintText: '**********'),
                  const SizedBox(height: 10),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Mobile Number',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.textColor),
                      )),
                  const SizedBox(height: 10),
                  const AuthDetails(hintText: '(**) ***-***-***'),
                  const SizedBox(height: 10),
                  Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Date of Birth',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.textColor),
                      )),
                  const SizedBox(height: 10),
                  const AuthDetails(hintText: 'DD/MM/YYYY'),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      context.go('/home');
                    },
                    style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.blueAccent),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                            horizontal: 80, vertical: 10))),
                    child: const Text(
                      'Register',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Or sign up with'),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an Account? "),
                      InkWell(
                        onTap: () => context.go('/Login'),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
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
