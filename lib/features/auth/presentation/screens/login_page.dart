import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/auth/presentation/widgets/auth_form.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    final password = _passwordController.text.trim();
    final email = _emailController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Email and Password cannot be empty")));
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (!mounted) return;

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Successfully logged in")));
        context.go("/home");
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Login Failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Failed: ${e.toString()}")));
    }

    setState(() {
      isLoading = false;
    });
  }

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
                    context.go('/home');
                  },
                ),
                const SizedBox(width: 90),
                const Text(
                  'Login',
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
                      'Welcome',
                      style: TextStyle(
                          color: AppPallete.headings,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Text(
                      'Video provides a powerful way to help you prove your point. When you click Online Video.'),
                  const SizedBox(height: 30),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Enter Email or Username',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.textColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AuthDetails(
                    hintText: 'example@example.com',
                    controller: _emailController,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Enter Password',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.textColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AuthDetails(
                    hintText: 'Enter Password',
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => context.go('/reset-password'),
                      child: const Text('Forgot Password',
                          style: TextStyle(color: AppPallete.headings)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FilledButton(
                    onPressed: isLoading ? null : _loginUser,
                    style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.blueAccent),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                            horizontal: 80, vertical: 10))),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Or sign in with'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      InkWell(
                        onTap: () => context.go('/register'),
                        child: const Text(
                          'Sign Up',
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
