import 'package:medical_app/core/errors/auth/failure.dart';
import 'package:medical_app/core/interfaces/usecase.dart';
import 'package:medical_app/features/auth/domain/repos/auth_repos.dart';
import 'package:fpdart/fpdart.dart';

class PasswordReset implements UseCase<void,PasswordResetParams> {
  final AuthRepos authRepos;
  const PasswordReset(this.authRepos);

  @override
  Future<Either<Failure, void>> call(PasswordResetParams params) async {
    return await authRepos.passwordResetOtp( params.email);
  }
}

class PasswordResetParams {
  final String email;

  PasswordResetParams({
    required this.email,
  });
}