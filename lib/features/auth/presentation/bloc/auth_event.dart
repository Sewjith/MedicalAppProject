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
