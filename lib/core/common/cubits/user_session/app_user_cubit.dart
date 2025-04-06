import 'package:flutter/material.dart';
import 'package:medical_app/core/common/entities/user_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState> {
  AppUserCubit() : super(AppUserInitial());

  void updateUser(UserType? user) {
    emit(user == null ? AppUserGuest() : AppUserLoggedIn(user));
  }

  void signOut() {
    emit(AppUserGuest());
  }

  // New: Set OTP pending state
  void setPendingOtp(String email) {
    emit(AppUserAwaitingOtp(email));
  }
}
