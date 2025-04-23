import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getCompletedAppointments() async {
    try {
      // First get completed appointments with doctor names
      final appointments = await _supabase
          .from('appointments')
          .select('id, doctor_name, doctor_id, appointment_date, appointment_status')
          .eq('appointment_status', 'complete')
          .order('appointment_date', ascending: false);

      if (appointments.isEmpty) return [];

      // Get doctor specialties for each appointment
      final doctorIds = appointments.map((a) => a['doctor_id']).toList();
      final doctors = await _supabase
          .from('doctors')
          .select('id, specialty')
          .inFilter('id', doctorIds);  // Changed from in_ to inFilter

      // Combine the data
      return appointments.map((appointment) {
        final doctor = doctors.firstWhere(
              (d) => d['id'] == appointment['doctor_id'],
          orElse: () => {'specialty': 'Unknown Specialty'},
        );
        return {
          ...appointment,
          'specialty': doctor['specialty'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to load appointments: ${e.toString()}');
    }
  }
}