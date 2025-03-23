import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/common/entities/user_type.dart';
import 'package:medical_app/core/common/widgets/no_params.dart';
import 'package:medical_app/features/auth/domain/usecases/active_user.dart';
import 'package:medical_app/features/auth/domain/usecases/user_login.dart';
import 'package:medical_app/features/auth/domain/usecases/user_register.dart';
import 'package:medical_app/features/auth/domain/usecases/user_sign_out.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRegister _userRegister;
  final UserLogin _userLogin;
  final ActiveUser _activeUser;
  final UserSignOut _userSignOut;
  final AppUserCubit _userCubit;

  AuthBloc({
    required UserRegister userRegister,
    required UserLogin userLogin,
    required ActiveUser activeUser,
    required UserSignOut userSignOut,
    required AppUserCubit userCubit,
  })  : _userRegister = userRegister,
        _userLogin = userLogin,
        _activeUser = activeUser,
        _userSignOut = userSignOut,
        _userCubit = userCubit,
        super(AuthInitial()) {
    on<AuthRegister>(_onAuthRegister);
    on<AuthLogin>(_onAuthLogin);
    on<AuthActiveUser>(_isActiveUser);
    on<AuthSignOut>(_onAuthSignOut);
  }

  void _isActiveUser(AuthActiveUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _activeUser(NoParams());
    res.fold(
      (fail) {
        _userCubit.signOut(); // Emit guest on failure
        emit(AuthFailed(fail.error));
      },
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthRegister(AuthRegister event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userRegister(UserRegisterParams(
      dob: event.dob,
      phone: event.phone,
      email: event.email,
      password: event.password,
    ));
    res.fold(
      (fail) => emit(AuthFailed(fail.error)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userLogin(
      UserLoginParams(email: event.email, password: event.password),
    );
    res.fold(
      (fail) => emit(AuthFailed(fail.error)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userSignOut(NoParams());
    res.fold(
      (fail) => emit(AuthFailed(fail.error)),
      (_) {
        _userCubit.signOut(); // Emit guest after sign-out
        emit(AuthInitial());
      },
    );
  }

  void _emitAuthSuccess(UserType user, Emitter<AuthState> emit) {
    _userCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}
