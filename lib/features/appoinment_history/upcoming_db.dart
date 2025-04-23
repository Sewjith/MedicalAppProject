import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpcomingDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUpcomingAppointments() async {
    try {
      final appointments = await _supabase
          .from('appointments')
          .select('id, doctor_name, doctor_id, appointment_date, appointment_time, appointment_status')
          .eq('appointment_status', 'upcoming')
          .order('appointment_date', ascending: true);

      if (appointments.isEmpty) return [];

      return await _processAppointments(appointments);
    } catch (e) {
      debugPrint('Error loading appointments: $e');
      throw Exception('Failed to load upcoming appointments. Please try again later.');
    }
  }

  Future<List<Map<String, dynamic>>> _processAppointments(List<dynamic> appointments) async {
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
      processedAppointments.add(_createAppointmentMap(appointment, doctor));
    }

    for (final appointment in noDoctorAppointments) {
      processedAppointments.add(_createAppointmentMap(appointment, {
        'specialty': 'No Specialty',
        'avatar_path': null,
      }));
    }

    return processedAppointments;
  }

  Map<String, dynamic> _createAppointmentMap(
      dynamic appointment,
      Map<String, dynamic> doctor,
      ) {
    final avatarPath = doctor['avatar_path'];
    final imageUrl = avatarPath != null
        ? '${_supabase.storage.from('avatars').getPublicUrl(avatarPath)}'
        : 'assets/images/default_doctor.png';

    return {
      ...appointment,
      'specialty': doctor['specialty'],
      'image_url': imageUrl,
      'date': _formatDate(appointment['appointment_date']),
      'time': _formatTime(appointment['appointment_time']),
    };
  }

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        final parsedDate = DateTime.parse(date);
        return '${_getWeekday(parsedDate.weekday)}, ${parsedDate.day} ${_getMonth(parsedDate.month)}';
      }
      return 'Unknown date';
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _formatTime(dynamic time) {
    if (time is String) {
      return time;
    }
    return 'Unknown time';
  }

  String _getWeekday(int weekday) {
    const weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return weekdays[weekday % 7];
  }

  String _getMonth(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}