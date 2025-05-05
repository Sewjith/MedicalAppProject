import 'package:flutter/material.dart';
import 'package:medical_app/features/medication_reminder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: '',
    anonKey: '',
  );

  Supabase.instance.client.storage.setAuth(
    Supabase.instance.client.auth.currentSession?.accessToken ?? '',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical App',
      home: Medication_Reminder(),
    );
  }
}
