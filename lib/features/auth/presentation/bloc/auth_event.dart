part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthRegister extends AuthEvent {
  final String email;
  final String password;
  final String phone;
  final String dob;

  AuthRegister(
      { required this.email, required this.password, required this.phone, required this.dob });
}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin(
      { required this.email, required this.password, });
}

final class AuthActiveUser extends AuthEvent {}

final class AuthSignOut extends AuthEvent {}

final class AuthRequestOtp extends AuthEvent {
  final String email;

  AuthRequestOtp(
    { required this.email }
  );
}

final class AuthVerifyOtp extends AuthEvent {
  final String email;
  final String otp;

  AuthVerifyOtp(
    { required this.email, required this.otp }
  );
}