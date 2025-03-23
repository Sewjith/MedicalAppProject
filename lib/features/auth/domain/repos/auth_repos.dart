import 'package:fpdart/fpdart.dart';
import 'package:medical_app/core/errors/auth/failure.dart';
import 'package:medical_app/core/common/entities/user_type.dart';

abstract interface class AuthRepos {
  Future<Either<Failure, UserType>> signUpWithEmailAndPasword({
    required String phone,
    required String email,
    required String password,
    required String dob,
  });
  Future<Either<Failure, UserType>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, UserType>> activeUser();
  Future<Either<Failure, void>> signOutUser();
  Future<Either<Failure, void>> requestEmailOtp(String email);
  Future<Either<Failure, UserType>> verifyEmailOtp(String email, String otp);

}