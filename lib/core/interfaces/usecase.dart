import 'package:fpdart/fpdart.dart';
import 'package:medical_app/core/errors/auth/failure.dart';

abstract interface class UseCase<UserType, Params> {
  Future<Either<Failure, UserType>> call(Params params);
}
