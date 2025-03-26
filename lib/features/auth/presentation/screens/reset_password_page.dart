import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/auth/presentation/widgets/auth_form.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/features/auth/presentation/widgets/form_validation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final supabase = Supabase.instance.client;
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _checkUserSession(); // Ensure the user is logged in before resetting password
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Ensure the user is authenticated when they open this screen
  Future<void> _checkUserSession() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      // If user is not authenticated, send them back to login
      context.go('/login');
    }
  }

  Future<void> _passwordReset() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await supabase.auth.updateUser(UserAttributes(password: password));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successful!")),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        context.go('/login'); // Redirect to login after reset
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
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
                const SizedBox(width: 70),
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.headings,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(35.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your new password below.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // New Password Input
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'New Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppPallete.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  AuthDetails(
                    hintText: 'Enter New Password',
                    controller: _passwordController,
                    validator: FormValidators.passwordValidation,
                    isPassword: !isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Confirm Password Input
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppPallete.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  AuthDetails(
                    hintText: 'Confirm Password',
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                    isPassword: !isConfirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Reset Password Button
                  Opacity(
                    opacity: isLoading ? 0.6 : 1.0,
                    child: FilledButton(
                      onPressed: isLoading ? null : _passwordReset,
                      style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.blueAccent),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Reset Password',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
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
