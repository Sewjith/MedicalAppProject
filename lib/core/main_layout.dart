import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/bottom_nav_bar.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';


class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {


  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();


    final userState = context.read<AppUserCubit>().state;
    String? role;
    if (userState is AppUserLoggedIn) {
      role = userState.user.role;
    }


    if (role == 'patient' && location.startsWith('/p_dashboard')) {
       return 0;
    }
    if (role == 'doctor' && location.startsWith('/d_dashboard')) {
       return 0;
    }
    if (location.startsWith('/home')) {
      return 0;
    }

    // --- Updated Chat Index Calculation ---
    // For Doctors, consider '/doctor/inbox' as the chat tab (index 1)
    if (role == 'doctor' && location.startsWith('/doctor/inbox')) {
       return 1;
    }
    // For Patients, '/chat/login' or '/chat/consultation' (handled by router) is chat (index 1)
    // We use '/chat/login' as the entry point check for the nav bar index
    if (role == 'patient' && location.startsWith('/chat/login')) {
       return 1;
    }
    // --- End Updated Chat ---


    if (location.startsWith('/patient/profile') || location.startsWith('/doctor/profile')) {
      return 2;
    }

    if (location.startsWith('/patient/appointment') || location.startsWith('/doctor/appointment')) {
      return 3;
    }

    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final userState = context.read<AppUserCubit>().state;

    switch (index) {
      case 0: // Home Icon

        if (userState is AppUserLoggedIn) {
          if (userState.user.role == 'patient') {
            context.go('/p_dashboard');
          } else if (userState.user.role == 'doctor') {
            context.go('/d_dashboard');
          } else {

            context.go('/home');
          }
        } else {

          context.go('/home');
        }
        break;
      case 1: // Chat Icon
        // *** FIX: Navigate based on role ***
        if (userState is AppUserLoggedIn) {
          if (userState.user.role == 'patient') {
            context.go('/chat/login'); // Patient goes to doctor selection chat screen
          } else if (userState.user.role == 'doctor') {
            context.go('/doctor/inbox'); // Doctor goes to their inbox
          } else {
             context.go('/login'); // Fallback if role unknown but logged in
          }
        } else {
           context.go('/login'); // Guest goes to login
        }
        break;
      case 2: // Person Icon (Profile)
        if (userState is AppUserLoggedIn) {
          if (userState.user.role == 'patient') {
            context.go('/patient/profile');
          } else if (userState.user.role == 'doctor') {
            context.go('/doctor/profile');
          } else {
            context.go('/login');
          }
        } else {
          context.go('/login');
        }
        break;
      case 3: // Calendar Icon (Appointments/Schedule)
        if (userState is AppUserLoggedIn) {
          if (userState.user.role == 'patient') {
            context.go('/patient/appointment/history');
          } else if (userState.user.role == 'doctor') {
            context.go('/doctor/appointment/schedule');
          } else {
            context.go('/login');
          }
        } else {
          context.go('/login');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: SafeArea(child: widget.child),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) => _onItemTapped(index, context),
      ),
    );
  }
}