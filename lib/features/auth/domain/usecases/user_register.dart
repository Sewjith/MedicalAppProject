import 'package:fpdart/src/either.dart';
import 'package:medical_app/core/errors/auth/failure.dart';
import 'package:medical_app/core/interfaces/usecase.dart';
import 'package:medical_app/features/auth/domain/repos/auth_repos.dart';

class UserRegister implements UseCase<String,UserRegisterParams> {
  final AuthRepos authRepos;
  const UserRegister(this.authRepos);

  @override
  Future<Either<Failure, String>> call(UserRegisterParams params) async {
    return await authRepos.signUpWithEmailAndPasword(phone: params.phone, dob: params.dob, email: params.email, password: params.password);
  }
}

class UserRegisterParams {
  final String phone;
  final String email;
  final String password;
  final String dob;

  UserRegisterParams({
    required this.phone,
    required this.dob,
    required this.email,
    required this.password
  });
}