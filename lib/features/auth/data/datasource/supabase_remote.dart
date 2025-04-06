import 'package:medical_app/core/errors/common/expection.dart';
import 'package:medical_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteSource {
  Session? get isActiveUser;

  Future<UserModel> signUpWithEmail({
    required String phone,
    required String email,
    required String password,
    required String dob,
  });

  Future<void> requestEmailOtp(String email);
  Future<void> passwordResetOtp(String email);


  Future<UserModel> verifyEmailOtp(String email, String otp);

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel?> getIsActiveUser();

  Future<void> signOut();
}

class AuthRemoteSourceImp implements AuthRemoteSource {
  final SupabaseClient supabaseClient;

  AuthRemoteSourceImp(this.supabaseClient);

  @override
  Future<UserModel> signUpWithEmail({
    required String phone,
    required String email,
    required String password,
    required String dob,
  }) async {
    try {
      final res = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {
          'phone': phone,
          'dob': dob,
        },
      );

      if (res.user == null) {
        throw const ServerException("User is not available");
      }

      // No need to request OTP again, Supabase already sends it
      return UserModel.fromJson(res.user!.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> requestEmailOtp(String email) async {
    try {
      await supabaseClient.auth.signInWithOtp(
        email: email,
      );
    } catch (e) {
      throw ServerException('Error sending OTP: $e');
    }
  }

  @override
  Future<UserModel> verifyEmailOtp(String email, String otp) async {
    try {
      final res = await supabaseClient.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.signup,
      );

      if (res.user == null) {
        throw const ServerException("Invalid OTP or email not verified");
      }

      return UserModel.fromJson(res.user!.toJson());
    } catch (e) {
      throw ServerException('OTP verification failed: $e');
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        throw const ServerException("Invalid credentials");
      }

      // Ensure the user is verified
      if (res.user!.emailConfirmedAt == null) {
        throw const ServerException("Please verify your email before logging in.");
      }

      return UserModel.fromJson(res.user!.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Session? get isActiveUser => supabaseClient.auth.currentSession;

  @override
  Future<UserModel?> getIsActiveUser() async {
    try {
      if (isActiveUser != null) {
        final session = await supabaseClient
            .from('Users')
            .select()
            .eq('id', isActiveUser!.user.id)
            .maybeSingle();

        if (session == null) {
          throw ServerException("User not found in database.");
        }

        return UserModel.fromJson(session).copyWith(
          email: isActiveUser!.user.email,
        );
      }
      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException("Failed to sign out: ${e.toString()}");
    }
  }
  
  @override
  Future<void> passwordResetOtp(String email)async {
     try {
      await supabaseClient.auth.signInWithOtp(
        email: email,
      );
    } catch (e) {
      throw ServerException('Error sending OTP: $e');
    }
  }
}
