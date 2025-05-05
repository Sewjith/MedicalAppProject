import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class Backend {
  static final SupabaseClient supabase = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> getAvailability(
      String doctorId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];

    final response = await supabase
        .from('availability')
        .select()
        .eq('available_date', dateStr)
        .eq('doctor_id', doctorId);

    if (response.isEmpty) {
      debugPrint('No availability data found for $dateStr for doctor $doctorId');
      return [];
    }

    return List<Map<String, dynamic>>.from(response);
  }

    static Future<bool> addAvailability(
      String doctorId, DateTime date, TimeOfDay startTime, TimeOfDay endTime) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final start = _formatTime(startTime);
    final end = _formatTime(endTime);

    final availabilityId = DateTime.now().millisecondsSinceEpoch.toString(); // Using timestamp for now

    try { 
        final response = await supabase.from('availability').insert({
          'doctor_id': doctorId,
          'available_date': dateStr,
          'start_time': start,
          'end_time': end,
          'status': 'active', 
          'availability_id': availabilityId,
        }); 

      
        if (response == null) {
            debugPrint('Error adding availability: Supabase insert operation returned null.');
            return false;
        }

      
        return true;

     } on PostgrestException catch (e) { // Catch specific Supabase errors
         debugPrint('Error adding availability (PostgrestException): ${e.message}');
         return false;
     } catch (e) { // Catch any other errors during insert
         debugPrint('Error adding availability: ${e.toString()}');
         return false;
     }
  }
  static Future<bool> deleteAvailability(String availabilityId) async {
    final response = await supabase
        .from('availability')
        .delete()
        .eq('availability_id', availabilityId);

    if (response.error != null) {
      debugPrint('Error deleting availability: ${response.error!.message}');
      return false;
    }

    return true;
  }

  static String _formatTime(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes:00';
  }
}