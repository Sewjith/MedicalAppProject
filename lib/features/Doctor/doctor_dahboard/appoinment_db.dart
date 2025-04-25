import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUpcomingAppointments() async {
    try {
      final data = await _supabase
          .from('appointments')
          .select('patient_name, patient_age, appointment_date, appointment_time')
          .order('appointment_date')
          .order('appointment_time');

      if (data.isEmpty) throw Exception('No appointments found');
      return data;
    } catch (e) {
      throw Exception('Failed to load appointments: ${e.toString()}');
    }
  }
}