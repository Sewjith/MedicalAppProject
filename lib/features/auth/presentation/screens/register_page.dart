import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medical_app/features/auth/presentation/widgets/auth_form.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _register() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();
    final dob = _dobController.text.trim();

    if (email.isEmpty || password.isEmpty || phone.isEmpty || dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthRegister(
            email: email,
            password: password,
            phone: phone,
            dob: dob,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSent) {
            debugPrint(
                "📲 Navigating to OTP screen with email: \${state.email}");
            context.go('/otp', extra: state.email);
          } else if (state is AuthFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      BackButton(onPressed: () => context.go('/home')),
                      const SizedBox(width: 70),
                      const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.headings,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(35.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            color: AppPallete.headings,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Sign up to start managing your medical records.',
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.textColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AuthDetails(
                          hintText: 'example@example.com',
                          controller: _emailController,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.textColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AuthDetails(
                          hintText: 'Enter Password',
                          controller: _passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Phone',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.textColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AuthDetails(
                          hintText: 'Enter Phone Number',
                          controller: _phoneController,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Date of Birth (YYYY-MM-DD)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.textColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AuthDetails(
                          hintText: 'YYYY-MM-DD',
                          controller: _dobController,
                        ),
                        const SizedBox(height: 30),
                        FilledButton(
                          onPressed: isLoading ? null : _register,
                          style: const ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.blueAccent),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.white),
                            padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 10),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            InkWell(
                              onTap: () => context.go('/login'),
                              child: const Text(
                                'Login',
                                style: TextStyle(color: Colors.blueAccent),
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
        },
      ),
    );
  }
}
