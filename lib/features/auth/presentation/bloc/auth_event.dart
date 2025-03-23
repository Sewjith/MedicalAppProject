part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthRegister extends AuthEvent {
  final String email;
  final String password;
  final String phone;
  final String dob;

  AuthRegister({
    required this.email,
    required this.password,
    required this.phone,
    required this.dob,
  }) {
    debugPrint('AuthRegister Event: email=$email, phone=$phone');
  }
}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin({
    required this.email,
    required this.password,
  }) {
    debugPrint('AuthLogin Event: email=$email');
  }
}

final class AuthActiveUser extends AuthEvent {
  AuthActiveUser() {
    debugPrint('AuthActiveUser Event Triggered');
  }
}

final class AuthSignOut extends AuthEvent {
  AuthSignOut() {
    debugPrint('AuthSignOut Event Triggered');
  }
}

final class AuthRequestOtp extends AuthEvent {
  final String email;

  AuthRequestOtp({
    required this.email,
  }) {
    debugPrint('AuthRequestOtp Event: email=$email');
  }
}

final class AuthVerifyOtp extends AuthEvent {
  final String email;
  final String otp;

  AuthVerifyOtp({
    required this.email,
    required this.otp,
  }) {
    debugPrint('AuthVerifyOtp Event: email=$email, otp=$otp');
  }
}
