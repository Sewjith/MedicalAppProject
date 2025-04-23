import 'package:flutter/foundation.dart'; // Add this import
import 'package:supabase_flutter/supabase_flutter.dart';

class  CancelledDb {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getCancelledAppointments() async {
    return _getAppointmentsByStatus('cancelled');
  }

  Future<List<Map<String, dynamic>>> _getAppointmentsByStatus(String status) async {
    try {
      final appointments = await _supabase
          .from('appointments')
          .select('id, doctor_name, doctor_id, appointment_date, appointment_status')
          .eq('appointment_status', status)
          .order('appointment_date', ascending: false);

      if (appointments.isEmpty) return [];

      final validAppointments = appointments.where((a) => a['doctor_id'] != null).toList();
      final noDoctorAppointments = appointments.where((a) => a['doctor_id'] == null).toList();

      final doctorIds = validAppointments.map((a) => a['doctor_id'] as String).toList();
      List<Map<String, dynamic>> doctors = [];

      if (doctorIds.isNotEmpty) {
        doctors = await _supabase
            .from('doctors')
            .select('id, specialty, avatar_path')
            .inFilter('id', doctorIds);
      }

      final processedAppointments = <Map<String, dynamic>>[];

      for (final appointment in validAppointments) {
        final doctor = doctors.firstWhere(
              (d) => d['id'] == appointment['doctor_id'],
          orElse: () => {
            'specialty': 'Unknown Specialty',
            'avatar_path': null,
          },
        );

        final avatarPath = doctor['avatar_path'];
        final imageUrl = avatarPath != null
            ? '${_supabase.storage.from('avatars').getPublicUrl(avatarPath)}'
            : 'assets/images/default_doctor.png';

        processedAppointments.add({
          ...appointment,
          'specialty': doctor['specialty'],
          'image_url': imageUrl,
        });
      }

      for (final appointment in noDoctorAppointments) {
        processedAppointments.add({
          ...appointment,
          'specialty': 'No Specialty',
          'image_url': 'assets/images/default_doctor.png',
        });
      }

      return processedAppointments;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading $status appointments: $e');
      }
      throw Exception('Failed to load $status appointments. Please try again later.');
    }
  }
}