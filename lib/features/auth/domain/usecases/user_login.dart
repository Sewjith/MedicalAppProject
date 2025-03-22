import 'package:medical_app/core/errors/auth/failure.dart';
import 'package:medical_app/core/interfaces/usecase.dart';
import 'package:medical_app/features/auth/domain/repos/auth_repos.dart';
import 'package:fpdart/fpdart.dart';

class UserLogin implements UseCase<String,UserLoginParams> {
  final AuthRepos authRepos;
  const UserLogin(this.authRepos);

  @override
  Future<Either<Failure, String>> call(UserLoginParams params) async {
    return await authRepos.signInWithEmailAndPassword( email: params.email, password: params.password);
  }
}

class UserLoginParams {
  final String email;
  final String password;

  UserLoginParams({
    required this.email,
    required this.password
  });
}