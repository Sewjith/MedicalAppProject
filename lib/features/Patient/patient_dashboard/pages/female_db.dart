import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getFemaleDoctors() async {
    try {
      final response = await _supabase
          .from('doctors')
          .select('''
            id,
            title,
            first_name,
            last_name,
            specialty,
            gender
          ''')
          .eq('gender', 'Female')
          .order('last_name', ascending: true);

      return response.map((doctor) {
        return {
          'id': doctor['id'],
          'title': doctor['title'],
          'firstName': doctor['first_name'],
          'lastName': doctor['last_name'],
          'specialty': doctor['specialty'],
          'gender': doctor['gender'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to load male doctors: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    try {
      final response = await _supabase
          .from('doctors')
          .select('''
            id,
            title,
            first_name,
            last_name,
            specialty,
            gender
          ''')
          .order('last_name', ascending: true);

      return response.map((doctor) {
        return {
          'id': doctor['id'],
          'title': doctor['title'],
          'firstName': doctor['first_name'],
          'lastName': doctor['last_name'],
          'specialty': doctor['specialty'],
          'gender': doctor['gender'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to load doctors: ${e.toString()}');
    }
  }
}

class FavoriteDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getPatientFavorites(String patientId) async {
    try {
      final response = await _supabase
          .from('favorites_doctors')
          .select('''
            doctor:doctors(
              id,
              title,
              first_name,
              last_name,
              specialty,
              gender
            ),
            created_at
          ''')
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);

      return response.map((fav) {
        final doctor = fav['doctor'];
        return {
          'id': doctor['id'],
          'title': doctor['title'],
          'firstName': doctor['first_name'],
          'lastName': doctor['last_name'],
          'specialty': doctor['specialty'],
          'gender': doctor['gender'],
          'createdAt': fav['created_at'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to load favorites: ${e.toString()}');
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