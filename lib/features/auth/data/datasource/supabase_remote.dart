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
  Future<UserModel> signInWithEmail({required String email, required String password}) async {
    try {
      final res = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
        );
      if (res.user == null){
        throw const ServerException("User is not available");
      }
      return UserModel.fromJson(res.user!.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel > signUpWithEmail({required String phone, required String email, required String password, required String dob}) async {
    try {
      final res = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {
          'phone': phone,
          'dob': dob,
          }
        );
      if (res.user == null){
        throw const ServerException("User is not available");
      }
      return UserModel.fromJson(res.user!.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
  
  @override
  Session? get isActiveUser => supabaseClient.auth.currentSession;
  
  @override
  Future<UserModel?> getIsActiveUser() async{
    try {
      if (isActiveUser != null) {
        final session = await supabaseClient.from('Users').select().eq(
          'id',
          isActiveUser!.user.id,
        );
        return UserModel.fromJson(session.first).copyWith(
          email: isActiveUser!.user.email
        ); // do for login and register too
      }
      return null;// update to the correct table
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

} 
  
