import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentService {
  final SupabaseClient _supabase;

  AppointmentService(this._supabase);

  Future<List<Map<String, dynamic>>> getDoctorAppointments(
      String doctorId, DateTime selectedDate) async {
    try {
      final startDate =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endDate = startDate.add(const Duration(days: 1));

      final response = await _supabase
          .from('appointments')
          .select('''
            appointment_id,
            appointment_datetime,
            status,
            notes,
            patient_name,
            patient_age,
            patient_gender,
            appointment_time
          ''')
          .eq('doctor_id', doctorId)
          .gte('appointment_datetime', startDate.toIso8601String())
          .lt('appointment_datetime', endDate.toIso8601String())
          .order('appointment_time', ascending: true);

      if (response.isNotEmpty) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch appointments: $e');
    }
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      await _supabase
          .from('appointments')
          .update({'status': status}).eq('appointment_id', appointmentId);
    } catch (e) {
      throw Exception('Failed to update appointment status: $e');
    }
  }
}
