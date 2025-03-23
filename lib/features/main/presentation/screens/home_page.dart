import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOut());
              context.go('/home'); // Navigate to home after sign-out
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: BlocBuilder<AppUserCubit, AppUserState>(
          builder: (context, state) {
            if (state is AppUserLoggedIn) {
              return Text(
                'Welcome, ${state.user.email}',
                style: const TextStyle(fontSize: 20),
              );
            }
            return const Text(
              'Welcome, Guest',
              style: TextStyle(fontSize: 20),
            );
          },
        ),
      ),
    );
  }
}
