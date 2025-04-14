import 'package:flutter/material.dart';
import 'package:medical_app/SymptomTrackerScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ipoouxwecvbxvsfomfaf.supabase.co',
    anonKey: 'your-anon-key',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SymptomTrackerScreen(),
    );
  }
}
