import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient? _supabase;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: '', // Replace with actual URL
      anonKey: '', // Replace with actual Anon Key
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
