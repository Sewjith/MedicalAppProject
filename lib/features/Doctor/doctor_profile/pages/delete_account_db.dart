import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DeleteAccountDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> archiveDoctorAccount({
    required String doctorId,
    required String inputPassword,
  }) async {
    try {
      // 1. Fetch complete doctor data
      final doctor = await _supabase
          .from('doctors')
          .select('''
            doctor_id,
            first_name,
            last_name,
            title,
            specialty,
            years_of_experience,
            phone_number,
            email,
            password_hash,
            qualifications,
            gender,
            amount,
            language
          ''')
          .eq('doctor_id', doctorId)
          .maybeSingle();

      if (doctor == null) {
        throw Exception('Doctor not found');
      }

      final storedHash = doctor['password_hash'] as String?;
      if (storedHash == null) {
        throw Exception('Password not set for this account');
      }

      final inputHash = _hashPassword(inputPassword);
      if (storedHash != inputHash) {
        throw Exception('Incorrect password');
      }

      final archiveResponse = await _supabase.from('deleted_doctors').insert({
        'doctor_id': doctor['doctor_id'],
        'first_name': doctor['first_name'],
        'last_name': doctor['last_name'],
        'title': doctor['title'],
        'specialty': doctor['specialty'],
        'years_of_experience': doctor['years_of_experience'],
        'phone_number': doctor['phone_number'],
        'email': doctor['email'],
        'password_hash': storedHash,
        'qualifications': doctor['qualifications'],
        'gender': doctor['gender'],
        'amount': doctor['amount'],
        'language': doctor['language'],
        'deleted_at': DateTime.now().toIso8601String(),
      }).select();

      if (archiveResponse.isEmpty) {
        throw Exception('Failed to archive doctor data');
      }

      try {
        final deleteResponse = await _supabase
            .from('doctors')
            .delete()
            .eq('doctor_id', doctorId);

        if (deleteResponse.error != null) {
          print('Delete failed but account archived: ${deleteResponse.error!.message}');
        }
      } catch (e) {
        print('Delete failed but account archived: $e');
      }

      print('Account archived successfully (doctor may still have appointments)');
    } catch (e) {
      print('Account archiving failed: $e');
      rethrow;
    }
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}