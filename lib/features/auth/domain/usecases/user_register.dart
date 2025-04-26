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
    if (params.role != 'patient') {
      return left(Failure('Only patients can register.'));
    }

    return await authRepos.signUpWithEmailAndPasword(
      role: params.role,
      phone: params.phone,
      gender: params.gender,
      dob: params.dob,
      email: params.email,
      password: params.password,
      firstname: params.firstname,
      lastname: params.lastname,
    );
  }
}

class UserRegisterParams {
  final String phone;
  final String email;
  final String gender;
  final String password;
  final String dob;
  final String firstname;
  final String lastname;
  final String role;

  UserRegisterParams({
    required this.phone,
    required this.role,
    required this.dob,
    required this.gender,
    required this.email,
    required this.password,
    required this.firstname,
    required this.lastname,
  });
}
