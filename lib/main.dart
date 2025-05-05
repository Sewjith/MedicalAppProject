import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'SymptomTrackerScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: '',
    anonKey: '',
  );

  runApp(const MyApp());
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
