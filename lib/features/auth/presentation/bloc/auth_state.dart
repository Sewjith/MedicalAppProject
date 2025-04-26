part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final UserType user;
  final String role;
  const AuthSuccess({required this.user, required this.role});
}

final class AuthFailed extends AuthState {
  final String error;
  const AuthFailed(this.error);
}

class AuthOtpSent extends AuthState {
  final String email;
  const AuthOtpSent(this.email);
}
