import 'package:medical_app/core/errors/common/expection.dart';
import 'package:medical_app/features/Patient/doctor-search/data/model/doctor_list_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

abstract interface class DoctorListRemoteSource {
  Future<List<DoctorListModel>> getAllDoctors();

  Future<List<Map<String, dynamic>>> searchDoctors(String query);

  Future<Map<String, dynamic>> getDoctorProfileDetails(String doctorId);
}

class DoctorListRemoteSourceImp implements DoctorListRemoteSource {
  final SupabaseClient supabaseClient;

  DoctorListRemoteSourceImp(this.supabaseClient);

  @override
  Future<List<DoctorListModel>> getAllDoctors() async {
    try {
      final res = await supabaseClient.from('doctors').select();

      if (res.isEmpty) {
        return [];
      }
      // Returns the original model type for now
      return (res as List).map((json) => DoctorListModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching all doctors: $e');
      throw ServerException("Failed to fetch doctors list: ${e.toString()}");
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchDoctors(String query) async {
    try {
      var dbQuery = supabaseClient
          .from('doctors')
          .select('''
            id,
            title,
            first_name,
            last_name,
            specialty,
            gender,
            years_of_experience,
            amount
          '''); // Select fields needed for list display

      if (query.isNotEmpty) {

        dbQuery = dbQuery.or(
          'first_name.ilike.%$query%,last_name.ilike.%$query%,specialty.ilike.%$query%',
        );
      }

      final response = await dbQuery.order('last_name', ascending: true);


      return List<Map<String, dynamic>>.from(response);

    } catch (e) {
      debugPrint('Error searching doctors with query "$query": $e');
      throw ServerException('Failed to search doctors: ${e.toString()}');
    }
  }


  @override
  Future<Map<String, dynamic>> getDoctorProfileDetails(String doctorId) async {
    if (doctorId.isEmpty) {
       throw ServerException('Doctor ID cannot be empty.');
    }
    try {
      final response = await supabaseClient
          .from('doctors')
          .select() // Select all columns for the profile
          .eq('id', doctorId)
          .maybeSingle(); // Use maybeSingle to handle not found case

       if (response == null) {
            // Throw a specific error if doctor not found
            throw ServerException('Doctor profile not found for ID: $doctorId');
       }

      return response; // Return the full map

    } on PostgrestException catch (e) {
       // Handle specific Supabase errors like 'Not Found'
       if (e.code == 'PGRST116') { // PGRST116: Row not found
           throw ServerException('Doctor profile not found for ID: $doctorId');
       }
       debugPrint('Supabase error loading profile for ID $doctorId: ${e.message}');
       throw ServerException('Database error loading profile: ${e.message}');
    }
    catch (e) {
      // Catch any other generic errors
      debugPrint('Generic error loading full doctor profile for ID $doctorId: $e');
      throw ServerException('Failed to load doctor profile: ${e.toString()}');
    }
  }
}