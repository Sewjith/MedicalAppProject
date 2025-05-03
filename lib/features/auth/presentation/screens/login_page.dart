import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Keep for navigating to register/reset
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

    context.read<AuthBloc>().add(
          AuthLogin(email: email, password: password),
        );
  }

  // Handles guest navigation
  void _continueAsGuest() {
    context.read<AppUserCubit>().signOut(); // Emits AppUserGuest state
    context.go('/home'); // Redirect to home as guest
  }

  @override
  Widget build(BuildContext context) {
    // Removed BlocSelector checking for isLoggedIn, as redirect happens globally

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // *** FIX: Removed navigation logic from here ***
          // Let the global listener in main.dart handle dashboard navigation.
          // This listener now only handles UI feedback specific to the login attempt.
          if (state is AuthSuccess) {
            // Optional: Show success message only if needed, might be redundant
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text("Successfully logged in")),
            // );

            // // --- REMOVED NAVIGATION ---
            // final role = state.user.role; // Get role from the logged-in user
            // // Navigate based on actual role from server
            // if (role == 'patient') {
            //   context.go('/p_dashboard');
            // } else if (role == 'doctor') {
            //   context.go('/d_dashboard');
            // } else {
            //   // fallback
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     const SnackBar(
            //         content: Text('Unknown role. Redirecting home.')),
            //   );
            //    context.go('/home'); // Fallback to home
            // }
            // --- END REMOVED NAVIGATION ---

          } else if (state is AuthFailed) {
             // Show specific failure message from the login attempt
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.error),
                  backgroundColor: AppPallete.errorColor // Use error color
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: SingleChildScrollView( // Added SingleChildScrollView
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: kToolbarHeight * 0.5), // Add top padding like AppBar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Use context.canPop() to decide whether to show back button
                      if(context.canPop())
                        BackButton(onPressed: () => context.pop()),
                      // If it cannot pop (e.g., initial route), don't show back button
                      // Or always navigate home: BackButton(onPressed: () => context.go('/home')),
                      const Spacer(), // Pushes title towards center
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 30, // Reduced size slightly
                          fontWeight: FontWeight.bold,
                          color: AppPallete.headings,
                        ),
                      ),
                      const Spacer(), // Pushes title towards center
                      SizedBox(width: AppBar().preferredSize.height), // Placeholder for symmetry if needed
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
                            'Welcome Back!', // Changed text
                            style: TextStyle(
                              color: AppPallete.headings,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8), // Reduce space
                        const Text(
                          'Log in to access your medical records and appointments.', // Updated text
                          style: TextStyle(color: AppPallete.greyColor, fontSize: 14), // Style text
                        ),
                        const SizedBox(height: 30),

                        // Email Input
                        Container( // Add label above field
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500, // Medium weight
                              color: AppPallete.textColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AuthDetails( // Assuming AuthDetails handles validation/styling
                          hintText: 'Enter your email',
                          controller: _emailController,
                          // Add validator if needed: validator: FormValidators.emailValidation,
                          // Add keyboardType: TextInputType.emailAddress
                        ),

                        const SizedBox(height: 20),

                        // Password Input
                         Container( // Add label above field
                           alignment: Alignment.centerLeft,
                           child: const Text(
                             'Password',
                             style: TextStyle(
                               fontSize: 16,
                               fontWeight: FontWeight.w500,
                               color: AppPallete.textColor,
                             ),
                           ),
                         ),
                        const SizedBox(height: 8),
                        AuthDetails(
                          hintText: 'Enter your password',
                          controller: _passwordController,
                          isPassword: true,
                           // Add validator if needed: validator: FormValidators.passwordValidation,
                        ),

                        const SizedBox(height: 8), // Reduced space
                        // Forgot Password Link
                        Container(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () => context.go('/forgot-password-email'), // Navigate to request link
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: AppPallete.headings),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Login Button
                        SizedBox( // Ensure button stretches
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _loginUser,
                            style: ElevatedButton.styleFrom( // Use theme style potentially
                              backgroundColor: AppPallete.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Consistent radius
                              ),
                            ),
                            // style: const ButtonStyle( // Old Style
                            //   backgroundColor: WidgetStatePropertyAll(Colors.blueAccent),
                            //   foregroundColor: WidgetStatePropertyAll(Colors.white),
                            //   padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 80, vertical: 10)),
                            // ),
                            child: isLoading
                                ? const SizedBox( // Smaller indicator
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 3))
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18), // Adjusted size
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Continue as Guest
                        TextButton(
                          onPressed: isLoading ? null : _continueAsGuest, // Disable while loading
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
                              onTap: isLoading ? null : () => context.go('/register'), // Disable while loading
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold), // Make bold
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