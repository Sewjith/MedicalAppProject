import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PasswordDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> updatePassword({
    required String userId,
    required String newPassword,
    required bool isDoctor,
  }) async {
    try {
      if (newPassword.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      final hashedPassword = _hashPassword(newPassword);
      final tableName = isDoctor ? 'doctors' : 'patients';
      final idColumn = isDoctor ? 'id' : 'id';

      final response = await _supabase
          .from(tableName)
          .update({'password_hash': hashedPassword})
          .eq(idColumn, userId)
          .select();

      if (response.isEmpty) {
        throw Exception('Password update failed: No records updated');
      }
    } catch (e) {
      print('Password update error: $e');
      rethrow;
    }
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}