import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medical_app/features/auth/presentation/widgets/auth_form.dart';

class ForgotPasswordEmailLink extends StatefulWidget {
  const ForgotPasswordEmailLink({super.key});

  @override
  State<ForgotPasswordEmailLink> createState() =>
      _ForgotPasswordEmailLinkState();
}

class _ForgotPasswordEmailLinkState extends State<ForgotPasswordEmailLink> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email")),
      );
      return;
    }

    context.read<AuthBloc>().add(AuthPasswordReset(email: email));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSent) {
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (Reduced Text Size + Removed Back Button)
                  const Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 32, // Reduced size
                      fontWeight: FontWeight.bold,
                      color: AppPallete.headings,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Description
                  const Text(
                    'Enter your email to receive a password reset OTP.',
                    style: TextStyle(
                      fontSize: 16, // Reduced size
                      color: AppPallete.textColor,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Email Input Label
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 16, // Reduced size
                      fontWeight: FontWeight.bold,
                      color: AppPallete.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Email Input Field
                  AuthDetails(
                    hintText: 'example@example.com',
                    controller: _emailController,
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  Center(
                    child: FilledButton(
                      onPressed: isLoading ? null : _sendResetLink,
                      style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.blueAccent),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Send Reset Link',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18, // Reduced size
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Navigate to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Remembered your password? ",
                        style: TextStyle(fontSize: 14), // Reduced size
                      ),
                      InkWell(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 14, // Reduced size
                          ),
                        ),
                      ),
                    ],
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
