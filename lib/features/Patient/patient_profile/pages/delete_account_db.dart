import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DeleteAccountDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> archivePatientAccount({
    required String patientId,
    required String inputPassword,
  }) async {
    try {
      // 1. Fetch complete patient data
      final patient = await _supabase
          .from('patients')
          .select('''
            id,
            patient_id,
            first_name,
            last_name,
            phone_number,
            email,
            date_of_birth,
            gender,
            address,
            password_hash,
            age,
            is_deleted,
            created_at
          ''')
          .eq('id', patientId)
          .maybeSingle();

      if (patient == null) {
        throw Exception('Patient not found');
      }

      final storedHash = patient['password_hash'] as String?;
      if (storedHash == null) {
        throw Exception('Password not set for this account');
      }

      final inputHash = _hashPassword(inputPassword);
      if (storedHash != inputHash) {
        throw Exception('Incorrect password');
      }

      final archiveResponse = await _supabase.from('deleted_patients').insert({
        'patient_id': patient['patient_id'],
        'first_name': patient['first_name'],
        'last_name': patient['last_name'],
        'phone_number': patient['phone_number'],
        'email': patient['email'],
        'date_of_birth': patient['date_of_birth'],
        'gender': patient['gender'],
        'address': patient['address'],
        'password_hash': storedHash,
        'age': patient['age'],
        'deleted_at': DateTime.now().toIso8601String(),
      }).select();

      if (archiveResponse.isEmpty) {
        throw Exception('Failed to archive patient data');
      }

      try {
        final deleteResponse = await _supabase
            .from('patients')
            .delete()
            .eq('id', patientId);

        if (deleteResponse.error != null) {
          print('Delete failed but account archived: ${deleteResponse.error!.message}');
        }
      } catch (e) {
        print('Delete failed but account archived: $e');
      }

      print('Account archived successfully');
    } catch (e) {
      print('Account archiving failed: $e');
      rethrow;
    }
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}