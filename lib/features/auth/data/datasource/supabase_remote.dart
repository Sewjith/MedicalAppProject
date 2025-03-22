import 'package:medical_app/core/errors/common/expection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteSource {
  Future<String> signUpWithEmail({
    required String phone,
    required String email,
    required String password,
    required String dob,
  });
  Future<String> signInWithEmail({
    required String email,
    required String password,
  });
}

class AuthRemoteSourceImp implements AuthRemoteSource {
  final SupabaseClient supabaseClient;
  AuthRemoteSourceImp(this.supabaseClient);
  @override
  Future<String> signInWithEmail({required String email, required String password}) {
    // TODO: implement signInWithEmail
    throw UnimplementedError();
  }

  @override
  Future<String> signUpWithEmail({required String phone, required String email, required String password, required String dob}) async {
    try {
      final res = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {
          'phone': phone,
          'dob': dob,
          }
        );
      if (res.user == "null"){
        throw const ServerExpection("User is not available");
      }
      return res.user!.id;
    } catch (e) {
      throw ServerExpection(e.toString());
    }
  }

} 
  
