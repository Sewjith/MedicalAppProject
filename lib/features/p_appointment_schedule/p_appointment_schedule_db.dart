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
        'patient_name': name,
        'patient_age': age,
        'patient_gender': gender,
        'notes': problemDesc,
        'appointment_datetime': date.toIso8601String(),
        'appointment_time': time,
        'doctor_name':doctor,
      });

      print("Supabase Response: $response");
      return true; // Success
    } catch (error) {
      print("Supabase Insert Error: $error"); // <-- PRINT ERROR
      return false; // Failure
    }
  }
}