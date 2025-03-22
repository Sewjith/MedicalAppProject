import 'package:fpdart/fpdart.dart';
import 'package:medical_app/core/errors/auth/failure.dart';

abstract interface class AuthRepos {
  Future<Either<Failure, String>> signUpWithEmailAndPasword({
    required String phone,
    required String email,
    required String password,
    required String dob,
  });
  Future<Either<Failure, String>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
}