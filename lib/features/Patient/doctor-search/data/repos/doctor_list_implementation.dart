import 'package:fpdart/src/either.dart';
import 'package:medical_app/core/common/entities/doctor.dart';
import 'package:medical_app/core/errors/auth/failure.dart';
import 'package:medical_app/core/errors/common/expection.dart';
import 'package:medical_app/features/Patient/doctor-search/data/source/supabase_remote_doctors.dart';
import 'package:medical_app/features/Patient/doctor-search/domain/repos/doctor_list_repos.dart';

class DoctorListImpl implements DoctorListRepos {
  final DoctorListRemoteSource remoteDoctorData;
  DoctorListImpl(this.remoteDoctorData);

  @override
  Future<Either<Failure, List<DoctorData>>> fetchDoctorsList({
    final String? id,
    final String? firstName,
    final String? lastName,
    final String? specialty,
    final String? number,
    final String? email,
  }) async {
    try {
      final doctorList = await remoteDoctorData.getAllDoctors();

      final List<DoctorData> userTypes = doctorList.map((doctor) {
        return DoctorData(
          id: doctor.id,
          firstName: doctor.firstName,
          lastName: doctor.lastName,
          specialty: doctor.specialty,
          number: doctor.number,
          email: doctor.email,
        );
      }).toList();

      return Right(userTypes);
    } on ServerException catch (e) {
      return Left(Failure(e.exception));
    }
  }

}