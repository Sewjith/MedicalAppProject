import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/common/entities/user_type.dart';
import 'package:medical_app/core/common/widgets/no_params.dart';
import 'package:medical_app/features/auth/domain/usecases/active_user.dart';
import 'package:medical_app/features/auth/domain/usecases/user_login.dart';
import 'package:medical_app/features/auth/domain/usecases/user_register.dart';
import 'package:medical_app/features/auth/domain/usecases/user_sign_out.dart';
import 'package:medical_app/features/auth/domain/usecases/request_otp.dart';
import 'package:medical_app/features/auth/domain/usecases/verify_otp.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRegister _userRegister;
  final UserLogin _userLogin;
  final ActiveUser _activeUser;
  final UserSignOut _userSignOut;
  final RequestOtp _requestOtp;
  final VerifyOtp _verifyOtp;
  final AppUserCubit _userCubit;

  AuthBloc({
    required UserRegister userRegister,
    required UserLogin userLogin,
    required ActiveUser activeUser,
    required UserSignOut userSignOut,
    required RequestOtp requestOtp,
    required VerifyOtp verifyOtp,
    required AppUserCubit userCubit,
  })  : _userRegister = userRegister,
        _userLogin = userLogin,
        _activeUser = activeUser,
        _userSignOut = userSignOut,
        _requestOtp = requestOtp,
        _verifyOtp = verifyOtp,
        _userCubit = userCubit,
        super(AuthInitial()) {
    // ✅ Registering all events with debug logs
    on<AuthRegister>(_onAuthRegister);
    on<AuthLogin>(_onAuthLogin);
    on<AuthActiveUser>(_isActiveUser);
    on<AuthSignOut>(_onAuthSignOut);
    on<AuthRequestOtp>(_onAuthRequestOtp);
    on<AuthVerifyOtp>(_onAuthVerifyOtp);

    // Debug all unhandled events
    on<AuthEvent>((event, emit) {
      debugPrint("⚠️ Unhandled Event: ${event.runtimeType}");
    });

    debugPrint('🚀 AuthBloc Initialized');
  }

  void _isActiveUser(AuthActiveUser event, Emitter<AuthState> emit) async {
    debugPrint("🔍 Checking for active user");
    emit(AuthLoading());
    final res = await _activeUser(NoParams());

    res.fold(
      (fail) {
        debugPrint("❌ Active user check failed: ${fail.error}");
        _userCubit.signOut();
        emit(AuthFailed(fail.error));
      },
      (user) {
        debugPrint("✅ Active user found: ${user.email}");
        _emitAuthSuccess(user, emit);
      },
    );
  }

  void _onAuthRegister(AuthRegister event, Emitter<AuthState> emit) async {
    debugPrint("📤 Registering user: ${event.email}");
    emit(AuthLoading());

    final res = await _userRegister(UserRegisterParams(
      role: event.role,
      dob: event.dob,
      gender: event.gender,
      phone: event.phone,
      email: event.email,
      password: event.password,
      firstname: event.firstname,
      lastname: event.lastname,
    ));

    res.fold(
      (fail) {
        debugPrint("❌ Registration failed: ${fail.error}");
        emit(AuthFailed(fail.error));
      },
      (_) {
        debugPrint("✅ Registration success: ${event.email}");
        // Skip manual OTP request—Supabase already sends the OTP
        _userCubit.setPendingOtp(event.email);
        emit(AuthOtpSent(event.email));
      },
    );
  }

  void _onAuthRequestOtp(AuthRequestOtp event, Emitter<AuthState> emit) async {
    debugPrint("📤 Requesting OTP for: ${event.email}");
    emit(AuthLoading());
    final res = await _requestOtp(RequestOtpParams(email: event.email));

    res.fold(
      (fail) {
        debugPrint("❌ OTP Request Failed: ${fail.error}");
        emit(AuthFailed(fail.error));
      },
      (_) {
        debugPrint("✅ OTP Sent Successfully: ${event.email}");
        _userCubit.setPendingOtp(event.email);
        emit(AuthOtpSent(event.email));
      },
    );
  }

  void _onAuthVerifyOtp(AuthVerifyOtp event, Emitter<AuthState> emit) async {
    debugPrint("🔐 Verifying OTP for: ${event.email}");
    emit(AuthLoading());
    final res = await _verifyOtp(VerifyOtpParams(
      email: event.email,
      otp: event.otp,
    ));

    res.fold(
      (fail) {
        debugPrint("❌ OTP Verification Failed: ${fail.error}");
        emit(AuthFailed(fail.error));
      },
      (user) {
        debugPrint("✅ OTP Verified Successfully: ${user.email}");
        _emitAuthSuccess(user, emit);
      },
    );
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    debugPrint("🔐 Logging in user: ${event.email}");
    emit(AuthLoading());
    final res = await _userLogin(
      UserLoginParams(email: event.email, password: event.password, role: event.role),
    );

    res.fold(
      (fail) {
        debugPrint("❌ Login failed: ${fail.error}");
        emit(AuthFailed(fail.error));
      },
      (user) {
        debugPrint("✅ Login successful: ${user.email}");
        _emitAuthSuccess(user, emit);
      },
    );
  }

  void _onAuthSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    debugPrint("👋 Signing out user");
    emit(AuthLoading());
    final res = await _userSignOut(NoParams());

    res.fold(
      (fail) {
        debugPrint("❌ Sign out failed: ${fail.error}");
        emit(AuthFailed(fail.error));
      },
      (_) {
        debugPrint("✅ User signed out successfully");
        _userCubit.signOut();
        emit(AuthInitial());
      },
    );
  }

  void _emitAuthSuccess(UserType user, Emitter<AuthState> emit) {
    debugPrint("📊 User session updated: ${user.email}");
    _userCubit.updateUser(user);
    emit(AuthSuccess(user: user, role: user.role));

  }
}
