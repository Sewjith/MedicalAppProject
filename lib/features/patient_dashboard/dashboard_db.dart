import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> getPatientFirstName(String patientId) async {
    try {
      final response = await _supabase
          .from('patients')
          .select('first_name')
          .eq('id', patientId)
          .single();

      return response['first_name'] as String;
    } catch (e) {
      throw Exception('Failed to load patient name: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> searchDoctors(String query) async {
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
          .or(
        'first_name.ilike.%$query%,last_name.ilike.%$query%,specialty.ilike.%$query%',
      )
          .order('last_name', ascending: true);

      return response.map((doctor) => {
        'id': doctor['id'],
        'title': doctor['title'],
        'firstName': doctor['first_name'],
        'lastName': doctor['last_name'],
        'specialty': doctor['specialty'],
        'gender': doctor['gender'],
      }).toList();
    } catch (e) {
      throw Exception('Failed to search doctors: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getDoctorDetails(String doctorId) async {
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
          .eq('id', doctorId)
          .single();

      return {
        'id': response['id'],
        'title': response['title'],
        'firstName': response['first_name'],
        'lastName': response['last_name'],
        'specialty': response['specialty'],
      };
    } catch (e) {
      throw Exception('Failed to load doctor details: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getMultipleDoctors(
      List<String> doctorIds) async {
    try {
      if (doctorIds.isEmpty) return [];

      final response = await _supabase
          .from('doctors')
          .select('''
            id,
            title,
            first_name,
            last_name,
            specialty
          ''')
          .inFilter('id', doctorIds);

      return (response as List).map((doctor) => {
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
              specialty
            )
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
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to load favorites: ${e.toString()}');
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

  Future<Map<String, dynamic>?> getUpcomingAppointment(String patientId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final response = await _supabase
          .from('appointments')
          .select('''
          id,
          appointment_time,
          appointment_date,
          appointment_status,
          doctor:doctor_id(
            id,
            title,
            first_name,
            last_name,
            specialty
          )
        ''')
          .eq('patient_id', patientId)
          .eq('appointment_status', 'upcoming')
          .gte('appointment_date', today.toIso8601String().split('T')[0])
          .order('appointment_date', ascending: true)
          .order('appointment_time', ascending: true)
          .limit(1)
          .maybeSingle();

      if (response != null && response['doctor'] != null) {
        return {
          'id': response['id'],
          'appointment_time': response['appointment_time'],
          'appointment_date': response['appointment_date'],
          'status': response['appointment_status'],
          'doctor': response['doctor'],
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load upcoming appointment: ${e.toString()}');
    }
  }
}