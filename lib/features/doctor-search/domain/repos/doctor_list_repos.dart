import 'package:fpdart/fpdart.dart';
import 'package:medical_app/core/common/entities/doctor.dart';
import 'package:medical_app/core/errors/auth/failure.dart';

abstract interface class DoctorListRepos {
  Future<Either<Failure, List<DoctorData>>> fetchDoctorsList({
    final String id,
    final String firstName,
    final String lastName,
    final String specialty,
    final String number,
    final String email,
  });
}