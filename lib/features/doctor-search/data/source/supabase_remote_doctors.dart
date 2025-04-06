import 'package:medical_app/core/errors/common/expection.dart';
import 'package:medical_app/features/doctor-search/domain/entities/doctor_profiles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class DoctorListRemoteSource {

  Future<List<DoctorProfiles>> getAllDoctors();

}

class DoctorListRemoteSourceImp implements DoctorListRemoteSource {
  final SupabaseClient supabaseClient;

  DoctorListRemoteSourceImp(this.supabaseClient);
  
  @override
  Future<List<DoctorProfiles>> getAllDoctors() async {
    try {
      final res = await supabaseClient.from('doctors').select();

      if (res.isEmpty) {
        throw const ServerException("No Docotrs Available");
      }

      return (res as List).map((json) => DoctorProfiles.fromJson(json)).toList();
    } catch (e) {
      throw ServerException("No Available Docotrs");
    }
  }


}
