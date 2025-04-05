import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardDB {
  final SupabaseClient _supabase = Supabase.instance.client;


  Future<Map<String, dynamic>> getDoctorBasicInfo(String doctorId) async {
    try {
      final data = await _supabase
          .from('doctors')
          .select('first_name, specialty')
          .eq('id', doctorId)
          .maybeSingle();

      if (data == null) {
        throw Exception('Doctor not found');
      }

      return data;
    } catch (e) {
      throw Exception('Failed to load doctor info: ${e.toString()}');
    }
  }


  Future<void> updateDoctorBasicInfo({
    required String doctorId,
    required String firstName,
    required String specialty,
  }) async {
    try {
      await _supabase
          .from('doctors')
          .update({
        'first_name': firstName,
        'specialty': specialty,
      })
          .eq('id', doctorId);
    } catch (e) {
      throw Exception('Update error: ${e.toString()}');
    }
  }
}