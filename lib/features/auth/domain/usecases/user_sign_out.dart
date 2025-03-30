import 'package:medical_app/core/common/widgets/no_params.dart';
import 'package:medical_app/core/errors/auth/failure.dart';
import 'package:medical_app/core/interfaces/usecase.dart';
import 'package:medical_app/features/auth/domain/repos/auth_repos.dart';
import 'package:fpdart/fpdart.dart';

class UserSignOut implements UseCase<void, NoParams> {
  final AuthRepos authRepos;
  const UserSignOut(this.authRepos);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await authRepos.signOutUser();
  }
}

