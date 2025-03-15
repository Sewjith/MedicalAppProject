import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordEmailLink extends StatefulWidget {
  const ForgotPasswordEmailLink({super.key});

  @override
  State<ForgotPasswordEmailLink> createState() =>
      _ForgotPasswordEmailLinkState();
}

class _ForgotPasswordEmailLinkState extends State<ForgotPasswordEmailLink> {
  final TextEditingController _emailController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await supabase.auth.resetPasswordForEmail(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Password reset link sent! Check your email.")),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        context.go('/login'); // Redirect to login after sending the link
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
        padding: const EdgeInsets.all(20.0),
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
                const SizedBox(width: 50),
                const Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.headings,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Enter your email to receive a password reset link.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Email Input
            Container(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Email',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.textColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),

            const SizedBox(height: 30),
            // Send Reset Link Button
            Opacity(
              opacity: isLoading ? 0.6 : 1.0,
              child: FilledButton(
                onPressed: isLoading ? null : _sendResetLink,
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.blueAccent),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Send Reset Link',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
