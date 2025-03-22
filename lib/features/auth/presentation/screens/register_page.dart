import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medical_app/features/auth/presentation/widgets/auth_form.dart';
import 'package:medical_app/features/auth/presentation/widgets/form_validation.dart';

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

  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _contactController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _registerAccount() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _contactController.text.trim();
    final dob = _dobController.text.trim();

    // Trigger the Bloc event for registration
    context.read<AuthBloc>().add(
          AuthRegister(
            email: email,
            password: password,
            phone : phone,
            dob: dob,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() => isLoading = true);
          } else {
            setState(() => isLoading = false);
          }

          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Check email for verification")),
            );
            context.go('/home'); // Redirect to home page after registration
          } else if (state is AuthFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  BackButton(onPressed: () => context.go('/login')),
                  const SizedBox(width: 65),
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
                          foregroundColor:
                              WidgetStatePropertyAll(Colors.white),
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
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
      ),
    );
  }
}
