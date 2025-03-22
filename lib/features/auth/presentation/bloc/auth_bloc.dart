import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/features/auth/domain/usecases/user_register.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRegister _userRegister;

  AuthBloc({required UserRegister userRegister})
      : _userRegister = userRegister,
        super(AuthInitial()) {
    on<AuthRegister>((event, emit) async {
      final res = await _userRegister(UserRegisterParams(
          dob: event.dob, phone: event.phone, email: event.email, password: event.password
        )
      );
      res.fold(
        (fail) => emit(AuthFailed(fail.error)),
        (success) => emit(AuthSuccess(success)),
      );
    });
  }
}
