import 'package:flutter/material.dart';
import 'package:medical_app/core/router.dart';
import 'package:medical_app/core/themes/app_themes.dart';
import 'package:medical_app/features/appoinment_history/appoinment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: '',
    anonKey: '',

  );
  Supabase.instance.client.storage.setAuth(
      Supabase.instance.client.auth.currentSession?.accessToken ?? ''
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
    return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        title: 'Medical App',
        theme: AppTheme.lightThemeMode,
        );
    }
}
