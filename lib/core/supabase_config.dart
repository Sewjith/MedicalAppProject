import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient? _supabase;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url:  "https://ipoouxwecvbxvsfomfaf.supabase.co", // Replace with actual URL
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlwb291eHdlY3ZieHZzZm9tZmFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIxNDAxMjQsImV4cCI6MjA1NzcxNjEyNH0.lXIIiGsmaiWLPvJhrAuwPjD_r_vcBfkGS0zaGtvuswI", // Replace with actual Anon Key
    );
    _supabase = Supabase.instance.client;
  }

  static SupabaseClient get supabase {
    if (_supabase == null) {
      throw Exception("Supabase is not initialized. Call initialize() first.");
    }
    return _supabase!;
  }
}
