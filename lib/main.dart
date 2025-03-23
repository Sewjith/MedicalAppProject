import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/int_dependencies.dart';
import 'package:medical_app/core/router.dart';
import 'package:medical_app/core/themes/app_themes.dart';
import 'package:medical_app/features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize dependencies (including Supabase)
    await initDependencies();
  } catch (e) {
    debugPrint('Error during initialization: $e');
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => initializedServices<AppUserCubit>()),
        BlocProvider(
          create: (context) => initializedServices<AuthBloc>()..add(AuthActiveUser()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.read<AppUserCubit>().updateUser(state.user);
        } else if (state is AuthFailed) {
          context.read<AppUserCubit>().updateUser(null);
        }
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        title: 'Medical App',
        theme: AppTheme.lightThemeMode,
      ),
    );
  }
}
