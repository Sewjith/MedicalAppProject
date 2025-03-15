import 'package:flutter/material.dart';
import 'package:medical_app/core/router.dart';
import 'package:medical_app/core/themes/app_themes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures async operations before runApp()

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_PROJECT_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      title: 'Medical App',
      theme: AppTheme.lightThemeMode,
    );
  }
}
