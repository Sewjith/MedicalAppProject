import 'package:medical_app/core/common/entities/user_type.dart';
import 'package:medical_app/core/errors/auth/failure.dart';
import 'package:medical_app/core/interfaces/usecase.dart';
import 'package:medical_app/features/auth/domain/repos/auth_repos.dart';
import 'package:fpdart/fpdart.dart';

class VerifyOtp implements UseCase<UserType, VerifyOtpParams> {
  final AuthRepos authRepos;
  const VerifyOtp(this.authRepos);

  @override
  Future<Either<Failure, UserType>> call(VerifyOtpParams params) async {
    return await authRepos.verifyEmailOtp(params.email, params.otp);
  }
}

class VerifyOtpParams {
  final String email;
  final String otp;
  const VerifyOtpParams({
    required this.email,
    required this.otp,
  });
}
