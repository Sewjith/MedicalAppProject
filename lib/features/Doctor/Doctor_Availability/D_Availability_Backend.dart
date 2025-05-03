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
    // Consider making availability_id a proper UUID if it needs to be truly unique
    // final availabilityId = Uuid().v4(); // Example using uuid package
    final availabilityId = DateTime.now().millisecondsSinceEpoch.toString(); // Using timestamp for now

    try { // Add try-catch block for the Supabase call itself
        final response = await supabase.from('availability').insert({
          'doctor_id': doctorId,
          'available_date': dateStr,
          'start_time': start,
          'end_time': end,
          'status': 'active', // Consider 'available' if that matches your schema logic better
          'availability_id': availabilityId,
        }); // Removed .select() as insert doesn't typically return the inserted row by default unless specified

        // --- Check for null response FIRST ---
        if (response == null) {
            debugPrint('Error adding availability: Supabase insert operation returned null.');
            return false;
        }

        // --- Now safely check for errors (if PostgrestResponse) ---
        // Supabase insert might not return PostgrestResponse directly in all cases/versions
        // You might need more robust error checking depending on the actual return type
        // For now, assuming it might return an object with an 'error' property if not null

        // If response has an error property (adapt if return type is different)
        // This check might need adjustment based on the actual return type of insert
        // For instance, insert might throw an exception directly on error in some setups.
        /*
        if (response.error != null) { // Example check - adapt if needed
          debugPrint('Error adding availability: ${response.error!.message}');
          return false;
        }
        */

        // If no error was thrown and response wasn't null, assume success
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