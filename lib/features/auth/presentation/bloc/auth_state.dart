part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final String user;
  const AuthSuccess(this.user);
}

final class AuthFailed extends AuthState {
  final String error;
  const AuthFailed(this.error);
}
