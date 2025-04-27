import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient? _supabase;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url:  "https://qgjnnocobueozglvqywc.supabase.co", // Replace with actual URL
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFnam5ub2NvYnVlb3pnbHZxeXdjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk2Mzk1NzYsImV4cCI6MjA1NTIxNTU3Nn0.E0C0E1c3hZ6DU1Yn8Zwxp81auO1hwzc4kxfXLHebQQM", // Replace with actual Anon Key
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
