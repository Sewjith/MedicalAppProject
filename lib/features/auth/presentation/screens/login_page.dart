import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medical_app/features/auth/presentation/widgets/auth_form.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handles login logic
  void _loginUser() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and Password cannot be empty")),
      );
      return;
    }

    context.read<AuthBloc>().add(AuthLogin(email: email, password: password));
  }

  // Handles guest navigation
  void _continueAsGuest() {
    context.read<AppUserCubit>().signOut(); // Emits AppUserGuest state
    context.go('/home'); // Redirect to home as guest
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppUserCubit, AppUserState, bool>(
      selector: (state) => state is AppUserLoggedIn,
      builder: (context, isLoggedIn) {
        // Redirect to home if already logged in
        if (isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/home');
          });
        }

        return Scaffold(
          body: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Successfully logged in")),
                );
                context.go('/home'); // Navigate to home after login
              } else if (state is AuthFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BackButton(onPressed: () => context.go('/home')),
                        const SizedBox(width: 90),
                        const Text(
                          'Login',
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Welcome',
                              style: TextStyle(
                                color: AppPallete.headings,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Text(
                            'Log in to access your medical records and book appointments.',
                          ),
                          const SizedBox(height: 30),

                          // Email Input
                          const Text(
                            'Enter Email or Username',
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

                          // Password Input
                          const Text(
                            'Enter Password',
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

                          const SizedBox(height: 2),
                          Container(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => context.go('/reset-password'),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: AppPallete.headings),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Login Button
                          FilledButton(
                            onPressed: isLoading ? null : _loginUser,
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
                                    'Login',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                          ),

                          const SizedBox(height: 20),

                          // Continue as Guest Button
                          TextButton(
                            onPressed: _continueAsGuest,
                            child: const Text(
                              'Continue as Guest',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Sign Up Redirect
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? "),
                              InkWell(
                                onTap: () => context.go('/register'),
                                child: const Text(
                                  'Sign Up',
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
              );
            },
          ),
        );
      },
    );
  }
}
