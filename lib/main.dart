import 'package:flutter/material.dart';
import 'package:medical_app/core/router.dart';
import 'package:medical_app/core/themes/app_themes.dart';
import 'package:medical_app/features/doctor_dahboard/firstpage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ipoouxwecvbxvsfomfaf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlwb291eHdlY3ZieHZzZm9tZmFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIxNDAxMjQsImV4cCI6MjA1NzcxNjEyNH0.lXIIiGsmaiWLPvJhrAuwPjD_r_vcBfkGS0zaGtvuswI',
  );

  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical App',
      theme: AppTheme.lightThemeMode,
      home: DoctorDashboard(),
    );
  }
}
