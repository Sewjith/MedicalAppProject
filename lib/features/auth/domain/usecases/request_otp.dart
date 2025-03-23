import 'package:medical_app/core/common/widgets/no_params.dart';
import 'package:medical_app/core/errors/auth/failure.dart';
import 'package:medical_app/core/interfaces/usecase.dart';
import 'package:medical_app/features/auth/domain/repos/auth_repos.dart';
import 'package:fpdart/fpdart.dart';

class RequestOtp implements UseCase<void, RequestOtpParams> {
  final AuthRepos authRepos;
  const RequestOtp(this.authRepos);

  @override
  Future<Either<Failure, void>> call(RequestOtpParams params) async {
    return await authRepos.requestEmailOtp(params.email);
  }
}

class RequestOtpParams {
  final String email;
  RequestOtpParams(
    {
      required this.email
    }
  );
}
