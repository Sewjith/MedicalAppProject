import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentDetailsDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getAppointmentDetails(String appointmentId) async {
    try {
      final response = await _supabase
          .from('appointments')
          .select('''
            id,
            patient_name,
            doctor_name,
            appointment_date,
            appointment_time,
            status,
            doctor_id,
            doctor:doctors(
              specialty,
              qualifications,
              avatar_path
            )
          ''')
          .eq('id', appointmentId)
          .single();

      if (response == null) throw Exception('Appointment not found');

      return {
        'appointment_id': response['id'] ?? 'N/A',
        'patient_name': response['patient_name'] ?? 'N/A',
        'doctor_name': response['doctor_name'] ?? 'N/A',
        'appointment_date': _formatDate(response['appointment_date']),
        'appointment_time': _formatTime(response['appointment_time']),
        'status': response['status'] ?? 'N/A',
        'notes': response['additional_notes'] ?? 'No additional notes',
        'specialty': response['doctor']['specialty'] ?? 'N/A',
        'qualifications': _formatQualifications(response['doctor']['qualifications']),
        'doctor_image': response['doctor']['avatar_path'] != null
            ? _supabase.storage.from('avatars').getPublicUrl(response['doctor']['avatar_path'])
            : null,
      };
    } catch (e) {
      throw Exception('Failed to load appointment details: ${e.toString()}');
    }
  }

}
  String _formatQualifications(List<dynamic>? qualifications) {
    if (qualifications == null || qualifications.isEmpty) return 'N/A';
    return qualifications.join('\n• ');
  }

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        final parsedDate = DateTime.parse(date);
        return '${_getWeekday(parsedDate.weekday)}, ${parsedDate.day} ${_getMonth(parsedDate.month)} ${parsedDate.year}';
      }
      return 'Unknown date';
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _formatTime(dynamic time) {
    try {
      if (time is String) {
        final parts = time.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = parts[1];
          final period = hour >= 12 ? 'PM' : 'AM';
          final displayHour = hour > 12 ? hour - 12 : hour;
          return '$displayHour:$minute $period';
        }
        return time;
      }
      return 'Unknown time';
    } catch (e) {
      return 'Unknown time';
    }
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
