import 'package:medical_app/core/errors/common/expection.dart';
import 'package:medical_app/features/doctor-search/data/model/doctor_list_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class DoctorListRemoteSource {

  Future<List<DoctorListModel>> getAllDoctors();

}

class DoctorListRemoteSourceImp implements DoctorListRemoteSource {
  final SupabaseClient supabaseClient;

  DoctorListRemoteSourceImp(this.supabaseClient);
  
  @override
  Future<List<DoctorListModel>> getAllDoctors() async {
    try {
      final res = await supabaseClient.from('doctors').select();

      if (res.isEmpty) {
        throw const ServerException("No Docotrs Available");
      }

      return (res as List).map((json) => DoctorListModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException("Failed to fetch doctors list");
    }
  }


}
