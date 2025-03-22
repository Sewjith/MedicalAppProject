import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/core/router.dart';
import 'package:medical_app/core/secrets/supabase_secrets.dart';
import 'package:medical_app/core/themes/app_themes.dart';
import 'package:medical_app/features/auth/data/datasource/supabase_remote.dart';
import 'package:medical_app/features/auth/data/repos/auth_repo_implementation.dart';
import 'package:medical_app/features/auth/domain/usecases/user_register.dart';
import 'package:medical_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseSecrets.supabaseUrl,
    anonKey: SupabaseSecrets.key,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            userRegister: UserRegister(
              AuthReposImpl(
                AuthRemoteSourceImp(Supabase.instance.client),
              ),
            ),
          ),
        ),
      ],
      child: const MyApp(), // Ensure const for better performance
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter, // Use the updated appRouter
      title: 'Medical App',
      theme: AppTheme.lightThemeMode,
    );
  }
}
