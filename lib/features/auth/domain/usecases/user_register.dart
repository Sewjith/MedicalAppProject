import 'package:medical_app/core/errors/auth/failure.dart';
import 'package:medical_app/core/interfaces/usecase.dart';
import 'package:medical_app/core/common/entities/user_type.dart';
import 'package:medical_app/features/auth/domain/repos/auth_repos.dart';
import 'package:fpdart/fpdart.dart';

class UserRegister implements UseCase<UserType, UserRegisterParams> {
  final AuthRepos authRepos;
  const UserRegister(this.authRepos);

  @override
  Future<Either<Failure, UserType>> call(UserRegisterParams params) async {
    return await authRepos.signUpWithEmailAndPasword(
        phone: params.phone,
        dob: params.dob,
        email: params.email,
        password: params.password);
  }
}

class UserRegisterParams {
  final String phone;
  final String email;
  final String password;
  final String dob;

  UserRegisterParams(
      {required this.phone,
      required this.dob,
      required this.email,
      required this.password});
}
