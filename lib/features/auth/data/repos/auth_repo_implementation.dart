import 'package:fpdart/src/either.dart';
import 'package:medical_app/core/errors/auth/failure.dart';
import 'package:medical_app/core/errors/common/expection.dart';
import 'package:medical_app/features/auth/data/datasource/supabase_remote.dart';
import 'package:medical_app/features/auth/domain/repos/auth_repos.dart';

class AuthReposImpl implements AuthRepos {
  final AuthRemoteSource remoteAuthData;
  AuthReposImpl(this.remoteAuthData);
  @override
  Future<Either<Failure, String>> signInWithEmailAndPassword(
      {required String email, required String password}) {
    // TODO: implement signInWithEmailAndPassword
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> signUpWithEmailAndPasword(
      {required String phone,
      required String dob,
      required String email,
      required String password}) async {
    try {
      final data = await remoteAuthData.signUpWithEmail(
          phone: phone, dob: dob, email: email, password: password);
      return right(data);
    } on ServerExpection catch (e) {
      return left(Failure(e.exception));
    }
  }
}
