import 'package:fpdart/src/either.dart';
import 'package:medical_app/core/common/entities/doctor.dart';
import 'package:medical_app/core/errors/auth/failure.dart';
import 'package:medical_app/core/interfaces/usecase.dart';
import 'package:medical_app/features/Patient/doctor-search/domain/repos/doctor_list_repos.dart';

class GetDoctors implements UseCase<List<DoctorData>, DoctorListParams> {
  final DoctorListRepos doctorListRepos;
  const GetDoctors(this.doctorListRepos);

  @override
  Future<Either<Failure, List<DoctorData>>> call(DoctorListParams params) async {
    return await doctorListRepos.fetchDoctorsList(
      id: params.id,
      firstName: params.firstName,
      lastName: params.lastName,
      specialty: params.specialty,
      number: params.number,
      email: params.email,
    );
  }
}

class DoctorListParams {
  final String id;
  final String firstName;
  final String lastName;
  final String specialty;
  final String number;
  final String email;

  DoctorListParams({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.specialty,
    required this.number,
    required this.email,
  });
}

