import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getPatientProfile(String patientId) async {
    try {
      final response = await _supabase
          .from('patients')
          .select()
          .eq('id', patientId)
          .maybeSingle();

      if (response == null) {
        throw Exception('Patient profile not found');
      }

      if (response['avatar_path'] != null && response['avatar_path'].isNotEmpty) {
        response['avatar_url'] = _supabase.storage
            .from('Patient Avatars')
            .getPublicUrl(response['avatar_path']);
      }

      return response;
    } catch (e) {
      throw Exception('Failed to load profile: ${e.toString()}');
    }
  }

  Future<void> updatePatientProfile({
    required String patientId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String dateOfBirth,
    required String gender,
    required String address,
    required int age,
    String? avatarPath,
  }) async {
    try {
      final updateData = {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'phone_number': phoneNumber.trim(),
        'email': email.trim(),
        'date_of_birth': dateOfBirth.trim(),
        'gender': gender.trim(),
        'address': address.trim(),
        'age': age,
        if (avatarPath != null && avatarPath.isNotEmpty)
          'avatar_path': avatarPath,
      };

      await _supabase
          .from('patients')
          .update(updateData)
          .eq('id', patientId);
    } catch (e) {
      throw Exception('Update failed: ${e.toString()}');
    }
  }

  Future<String?> uploadAvatar(String patientId, String filePath) async {
    try {
      final fileExt = filePath.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(fileExt)) {
        throw Exception('Only JPG/PNG images allowed');
      }

      final fileName = 'avatar-$patientId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final storagePath = 'public/$fileName';

      await _supabase.storage
          .from('Patient Avatars')
          .upload(
        storagePath,
        File(filePath),
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
          contentType: 'image/$fileExt',
        ),
      );

      return storagePath;
    } catch (e) {
      throw Exception('Avatar upload failed: ${e.toString()}');
    }
  }
}