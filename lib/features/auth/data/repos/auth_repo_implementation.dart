import 'package:fpdart/fpdart.dart';
import 'package:medical_app/core/errors/auth/failure.dart';
import 'package:medical_app/core/errors/common/expection.dart';
import 'package:medical_app/features/auth/data/datasource/supabase_remote.dart';
import 'package:medical_app/core/common/entities/user_type.dart';
import 'package:medical_app/features/auth/domain/repos/auth_repos.dart';

class AuthReposImpl implements AuthRepos {
  final AuthRemoteSource remoteAuthData;
  AuthReposImpl(this.remoteAuthData);

  @override
  Future<Either<Failure, UserType>> signInWithEmailAndPassword({
    required String email,
    required String password,
    required String role,
  }) async {
    return _getUserDetails(
      () => remoteAuthData.signInWithEmail(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, UserType>> signUpWithEmailAndPasword({
    required String phone,
    required String dob,
    required String gender,
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    required String role,
  }) async {
    return _getUserDetails(
      () => remoteAuthData.signUpWithEmail(
        phone: phone,
        dob: dob,
        gender: gender,
        email: email,
        password: password,
        firstname: firstname,
        lastname: lastname,
      ),
    );
  }

  Future<Either<Failure, UserType>> _getUserDetails(
    Future<UserType> Function() userDetails,
  ) async {
    try {
      final user = await userDetails();
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.exception));
    }
  }

  @override
  Future<Either<Failure, UserType>> activeUser() async {
    try {
      final user = await remoteAuthData.getIsActiveUser();
      if (user == null) {
        return left(Failure("No user logged in"));
      }
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOutUser() async {
    try {
      await remoteAuthData.signOut();
      return right(unit); // Use `unit` to represent a successful void result
    } on ServerException catch (e) {
      return left(Failure(e.exception));
    }
  }

  @override
  Future<Either<Failure, Unit>> requestEmailOtp(String email) async {
    try {
      await remoteAuthData.requestEmailOtp(email);
      return right(unit); // Use `unit` to represent a successful void result
    } on ServerException catch (e) {
      return left(Failure(e.exception));
    }
  }

  @override
  Future<Either<Failure, UserType>> verifyEmailOtp(
      String email, String otp) async {
    try {
      final user = await remoteAuthData.verifyEmailOtp(email, otp);
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.exception));
    }
  }
}
