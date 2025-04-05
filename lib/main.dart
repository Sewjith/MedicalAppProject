import 'package:flutter/material.dart';
import 'package:flutter_application_1/Digital_Health_Record/digital_health_record_UI.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ipoouxwecvbxvsfomfaf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlwb291eHdlY3ZieHZzZm9tZmFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIxNDAxMjQsImV4cCI6MjA1NzcxNjEyNH0.lXIIiGsmaiWLPvJhrAuwPjD_r_vcBfkGS0zaGtvuswI',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Digital Health Records',
      home: DigitalHealthRecordUI(),
    );
  }
}
