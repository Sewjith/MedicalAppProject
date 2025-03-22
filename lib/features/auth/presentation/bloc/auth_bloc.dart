import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/features/auth/domain/usecases/user_login.dart';
import 'package:medical_app/features/auth/domain/usecases/user_register.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRegister _userRegister;
  final UserLogin _userLogin;

  AuthBloc({
    required UserRegister userRegister,
    required UserLogin userLogin,
  })  : _userRegister = userRegister,
        _userLogin = userLogin,
        super(AuthInitial()) {
    on<AuthRegister>(_onAuthRegister);
    on<AuthLogin>(_onAuthLogin);
  }

  void _onAuthRegister(AuthRegister event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userRegister(UserRegisterParams(
        dob: event.dob,
        phone: event.phone,
        email: event.email,
        password: event.password));
    res.fold(
      (fail) => emit(AuthFailed(fail.error)),
      (success) => emit(AuthSuccess(success)),
    );
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userLogin(UserLoginParams(
        email: event.email,
        password: event.password));
    res.fold(
      (fail) => emit(AuthFailed(fail.error)),
      (success) => emit(AuthSuccess(success)),
    );
  }
}
