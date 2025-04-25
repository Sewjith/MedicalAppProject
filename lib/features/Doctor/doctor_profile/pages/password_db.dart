import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PasswordDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> updatePassword({
    required String doctorId,
    required String newPassword,
  }) async {
    try {
      if (newPassword.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      final hashedPassword = _hashPassword(newPassword);

      final response = await _supabase
          .from('doctors')
          .update({'password_hash': hashedPassword})
          .eq('id', doctorId)
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