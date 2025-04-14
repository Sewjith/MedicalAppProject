import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/int_dependencies.dart';
import 'package:medical_app/core/router.dart';
import 'package:medical_app/core/supabase_config.dart';
import 'package:medical_app/core/themes/app_themes.dart';
import 'package:medical_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ipoouxwecvbxvsfomfaf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlwb291eHdlY3ZieHZzZm9tZmFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIxNDAxMjQsImV4cCI6MjA1NzcxNjEyNH0.lXIIiGsmaiWLPvJhrAuwPjD_r_vcBfkGS0zaGtvuswI',
  );

  runApp(MyApp());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize dependencies (including Supabase, get_it setup)
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
          create: (context) => initializedServices<AuthBloc>()..add(AuthActiveUser()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          final userCubit = context.read<AppUserCubit>();
          if (state is AuthSuccess) {
            debugPrint('🔐 Authenticated: ${state.user.email}');
            userCubit.updateUser(state.user);
          } else if (state is AuthFailed) {
            debugPrint('❌ Authentication Failed: ${state.error}');
            userCubit.signOut();
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