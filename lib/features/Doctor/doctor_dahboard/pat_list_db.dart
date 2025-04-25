import 'package:supabase_flutter/supabase_flutter.dart';

class PatListDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAllPatientsBasicInfo() async {
    try {
      final data = await _supabase
          .from('patients')
          .select('first_name,last_name, Age, gender');

      if (data.isEmpty) throw Exception('No patients found');
      return data;
    } catch (e) {
      throw Exception('Failed to load patients: ${e.toString()}');
    }
  }
}