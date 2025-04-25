import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;

  Future<bool> bookAppointment({
    required String name,
    required int age,
    required String gender,
    required String problemDesc,
    required DateTime date,
    required String time,
    required String doctor,
  }) async {
    try {
      final response = await supabase.from('appointments').insert({
        'name': name,
        'age': age,
        'gender': gender,
        'problemDesc': problemDesc,
        'date': date.toIso8601String(),
        'time': time,
        'doctor':doctor,
      });

      print("Supabase Response: $response");
      return true; // Success
    } catch (error) {
      print("Supabase Insert Error: $error"); // <-- PRINT ERROR
      return false; // Failure
    }
  }
}