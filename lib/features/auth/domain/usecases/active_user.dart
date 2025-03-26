import 'package:medical_app/core/common/widgets/no_params.dart';
import 'package:medical_app/core/errors/auth/failure.dart';
import 'package:medical_app/core/interfaces/usecase.dart';
import 'package:medical_app/core/common/entities/user_type.dart';
import 'package:medical_app/features/auth/domain/repos/auth_repos.dart';
import 'package:fpdart/fpdart.dart';

class ActiveUser implements UseCase<UserType, NoParams> {
  final AuthRepos authRepos;
  const ActiveUser(this.authRepos);

  @override
  Future<Either<Failure, UserType>> call(NoParams params) async {
    return await authRepos.activeUser();
  }
}

