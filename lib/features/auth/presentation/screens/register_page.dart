import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/auth/presentation/widgets/form_validation.dart';
import 'package:medical_app/features/auth/presentation/widgets/auth_form.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _contactController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _registerAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _contactController.text.trim();
    final dob = _dobController.text.trim();

    setState(() {
      isLoading = true;
    });
    try {
      final AuthResponse registerUser = await supabase.auth.signUp(
        email: username,
        password: password,
        data: {
          'phone': phone,
          'birth': dob,
        },
      );

      if (!mounted) return;

      if (registerUser.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Check email for verification")));
        context.go('/home');
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Registration Failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to register")));
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
                    context.go('/login');
                  },
                ),
                const SizedBox(width: 65),
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AuthDetails(
                      hintText: 'example@example.com',
                      controller: _emailController,
                      validator: FormValidators.emailValidation,
                    ),
                    const SizedBox(height: 10),
                    AuthDetails(
                      hintText: '**********',
                      controller: _passwordController,
                      validator: FormValidators.passwordValidation,
                    ),
                    const SizedBox(height: 10),
                    AuthDetails(
                      hintText: '(**) ***-***-***',
                      controller: _contactController,
                      validator: FormValidators.phoneValidation,
                    ),
                    const SizedBox(height: 10),
                    AuthDetails(
                      hintText: 'DD/MM/YYYY',
                      controller: _dobController,
                      validator: FormValidators.dobValidation,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: isLoading ? null : _registerAccount,
                      style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.blueAccent),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                              horizontal: 80, vertical: 10))),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Register',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Or sign up with'),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an Account? "),
                        InkWell(
                          onTap: () => context.go('/login'),
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
            ),
          ],
        ),
      ),
    );
  }
}
