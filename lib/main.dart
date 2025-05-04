import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter for GoRouterState
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/int_dependencies.dart';
import 'package:medical_app/core/router.dart'; // Import the appRouter instance
import 'package:medical_app/core/themes/app_themes.dart';
import 'package:medical_app/features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initDependencies();
    debugPrint('✅ Dependencies initialized successfully.');
  } catch (e) {
    debugPrint('❌ Error during initialization: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => initializedServices<AppUserCubit>()),
        BlocProvider(
          create: (_) => initializedServices<AuthBloc>()..add(AuthActiveUser()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          final userCubit = context.read<AppUserCubit>();
          debugPrint(
              "--- AuthBloc Listener Received State: ${state.runtimeType} ---");

          if (state is AuthSuccess) {
            final receivedRole = state.role; // Store role locally for clarity
            final userEmail = state.user.email;
            debugPrint(
                "AuthSuccess Details: Role='${receivedRole}', Email='${userEmail}'");

            // Update the user session state FIRST
            userCubit.updateUser(state.user);
            debugPrint("AppUserCubit state updated.");

            // Perform navigation AFTER cubit update
            if (receivedRole == 'patient') {
              debugPrint(
                  ">>> Role MATCHED 'patient'. Navigating to /p_dashboard via appRouter.go");
              // Use Future.microtask to ensure navigation happens after current event loop
              Future.microtask(() => appRouter.go('/p_dashboard'));
            } else if (receivedRole == 'doctor') {
              debugPrint(
                  ">>> Role MATCHED 'doctor'. Navigating to /d_dashboard via appRouter.go");
              Future.microtask(() => appRouter.go('/d_dashboard'));
            } else {
              debugPrint(
                  ">>> Role did NOT match 'patient' or 'doctor' (was '${receivedRole}'). Navigating to /home via appRouter.go");
              Future.microtask(() => appRouter.go('/home'));
            }
          } else if (state is AuthFailed) {
            debugPrint("AuthFailed Details: Error='${state.error}'");
            userCubit.signOut();
          } else if (state is AuthInitial) {
            debugPrint("AuthInitial Detected.");
            // Optional: Add logout/fallback logic if needed
          }
        },
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          title: 'Medical App',
          theme: AppTheme.lightThemeMode,
        ),
      ),
    );
  }
}
