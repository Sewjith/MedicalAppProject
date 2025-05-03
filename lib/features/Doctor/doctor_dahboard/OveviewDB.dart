import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class OverviewDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> getNewAppointments(String doctorId) async {
    try {
      // *** FIX: Correct count syntax ***
      final response = await _supabase
          .from('appointments')
          .select() // Select something (or nothing specific if just counting)
          .eq('doctor_id', doctorId)
          .eq('appointment_status', 'upcoming')
          .count(CountOption.exact); // Chain .count() correctly

      return response.count ?? 0;
    } catch (e) {
      print('Error getting new appointments: $e');
      throw Exception('Failed to get new appointments');
    }
  }

  Future<int> getTotalPatients(String doctorId) async {
    // This still counts ALL patients. Needs schema adjustment or different logic
    // for doctor-specific patient count.
    try {
      // *** FIX: Correct count syntax ***
       final response = await _supabase
           .from('patients')
           .select() // Select something
           .count(CountOption.exact); // Chain .count()
       return response.count ?? 0;
    } catch (e) {
       print('Error getting total patients: $e');
       throw Exception('Failed to get total patients');
    }
  }

  Future<double> getTotalEarnings(String doctorId) async {
    try {
      final response = await _supabase
          .from('payments') // Assuming an 'earnings' or 'payments' table linked to doctor
          .select('amount')
          .eq('doctor_id', doctorId) // Filter by doctor_id
          .eq('status', 'completed'); // Example: only count completed payments

      if (response.isEmpty) return 0.0;

      // Ensure correct type casting
      return response.fold<double>(
        0.0,
            (sum, item) {
              final amount = item['amount'];
              if (amount is num) {
                 return sum + amount.toDouble();
              }
              return sum; // Skip if amount is not a number
            }
      );
    } catch (e) {
      print('Error getting total earnings: $e');
      throw Exception('Failed to get total earnings');
    }
  }


  // These might remain global or could be filtered by doctorId if relevant
  Future<List<double>> getPatientRegistrations({String? doctorId}) async {
    try {
      final response = await _supabase
          .from('patients') // Assuming you track registration time here
          .select('created_at')
          .order('created_at', ascending: false);

      return _processDailyCount(response, 'created_at');
    } catch (e) {
      print('Error getting patient registrations: $e');
      throw Exception('Failed to get patient registrations');
    }
  }

  Future<List<double>> getAppointmentBookings({String? doctorId}) async {
    try {
      var query = _supabase
          .from('appointments')
          .select('created_at'); // Assuming 'created_at' is booking time

      if (doctorId != null) {
        query = query.eq('doctor_id', doctorId); // Filter if doctorId is provided
      }

      final response = await query.order('created_at', ascending: false);
      return _processDailyCount(response, 'created_at');
    } catch (e) {
       print('Error getting appointment bookings: $e');
       throw Exception('Failed to get appointment bookings');
    }
  }

  List<double> _processDailyCount(List<dynamic> data, String dateField) {
    final now = DateTime.now();
    final dailyCounts = List<double>.filled(7, 0.0);

    for (var item in data) {
      final dateValue = item[dateField];
      if (dateValue != null) {
         try {
          final date = DateTime.parse(dateValue as String).toLocal();
          final daysAgo = now.difference(DateTime(date.year, date.month, date.day)).inDays;

          if (daysAgo >= 0 && daysAgo < 7) {
             dailyCounts[6 - daysAgo] += 1.0;
          }
         } catch(e) {
            print("Error parsing date '$dateValue': $e");
         }
      }
    }
    print("Daily Counts ($dateField): $dailyCounts");
    return dailyCounts;
  }
}