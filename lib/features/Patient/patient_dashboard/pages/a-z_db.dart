import 'package:supabase_flutter/supabase_flutter.dart';

class AZDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    try {
      final response = await _supabase
          .from('doctors')
          .select('''
            id,
            title,
            first_name,
            last_name,
            specialty
          ''')
          .order('first_name', ascending: true);

      return response.map((doctor) => {
        'id': doctor['id'],
        'title': doctor['title'],
        'firstName': doctor['first_name'],
        'lastName': doctor['last_name'],
        'specialty': doctor['specialty'],
      }).toList();
    } catch (e) {
      throw Exception('Failed to load doctors: ${e.toString()}');
    }
  }

  Future<void> addFavorite(String patientId, String doctorId) async {
    try {
      await _supabase.from('favorites_doctors').insert({
        'patient_id': patientId,
        'doctor_id': doctorId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add favorite: ${e.toString()}');
    }
  }

  Future<void> removeFavorite(String patientId, String doctorId) async {
    try {
      await _supabase
          .from('favorites_doctors')
          .delete()
          .eq('patient_id', patientId)
          .eq('doctor_id', doctorId);
    } catch (e) {
      throw Exception('Failed to remove favorite: ${e.toString()}');
    }
  }

  Future<bool> isDoctorFavorited(String patientId, String doctorId) async {
    try {
      final response = await _supabase
          .from('favorites_doctors')
          .select()
          .eq('patient_id', patientId)
          .eq('doctor_id', doctorId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check favorite status: ${e.toString()}');
    }
  }
}