import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorHistoryDB {
  final _supabase = Supabase.instance.client;

  // Generic fetcher
  Future<List<Map<String, dynamic>>> _fetchAppointmentsByStatus(
      String doctorId, List<String> statuses) async {
    try {
      final response = await _supabase
          .from('appointments')
          .select('''
            appointment_id,
            appointment_date,
            appointment_time,
            appointment_status,
            notes,
            patient_name,
            patient_age,
            patient_gender,
            patient_id 
          ''')
          .eq('doctor_id', doctorId)
          .inFilter('appointment_status', statuses)
          .order('appointment_date', ascending: false)
          .order('appointment_time', ascending: false);

      // Ensure response is treated as a List
      return List<Map<String, dynamic>>.from(response);

    } catch (e) {
      debugPrint("Error fetching doctor appointments status $statuses: $e");
      if (e is PostgrestException) {
         throw Exception('Database error fetching history: ${e.message}');
      }
      throw Exception('Failed to load consultation history.');
    }
  }

  // Specific methods for each tab (These MUST exist)
  Future<List<Map<String, dynamic>>> getCompletedAppointments(String doctorId) async {
    return _fetchAppointmentsByStatus(doctorId, ['completed']);
  }

  Future<List<Map<String, dynamic>>> getUpcomingAppointments(String doctorId) async {
    return _fetchAppointmentsByStatus(doctorId, ['upcoming']);
  }

  Future<List<Map<String, dynamic>>> getCancelledAppointments(String doctorId) async {
    return _fetchAppointmentsByStatus(doctorId, ['cancelled']);
  }


  // Helper to format Date and Time consistently
  String formatAppointmentDateTime(String? dateStr, String? timeStr) {
    if (dateStr == null) return 'Date N/A';
    try {
      final date = DateTime.parse(dateStr);
      String formattedDate = DateFormat('MMM dd, yyyy').format(date); // Corrected DateFormat pattern
      String formattedTime = 'Time N/A';
      if (timeStr != null) {
         try {
           // Assuming timeStr is HH:mm:ss
           final parsedTime = DateFormat('HH:mm:ss').parseStrict(timeStr);
           formattedTime = DateFormat('h:mm a').format(parsedTime); // Format as 10:30 AM/PM
         } catch (e) {
           formattedTime = timeStr; // Fallback
         }
      }
      return '$formattedDate • $formattedTime';
    } catch (e) {
       return 'Invalid Date';
    }
  }
}