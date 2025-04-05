import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getDoctorProfile(String doctorId) async {
    try {
      final response = await _supabase
          .from('doctors')
          .select()
          .eq('id', doctorId)
          .maybeSingle();

      if (response == null) {
        throw Exception('Doctor profile not found');
      }

      if (response['avatar_path'] != null && response['avatar_path'].isNotEmpty) {
        response['avatar_url'] = _supabase.storage
            .from('Doctor Avatars')
            .getPublicUrl(response['avatar_path']);
      }

      return response;
    } catch (e) {
      throw Exception('Failed to load profile: ${e.toString()}');
    }
  }

  Future<void> updateDoctorProfile({
    required String doctorId,
    required String firstName,
    required String lastName,
    required String title,
    required String specialty,
    required int yearsOfExperience,
    required String phoneNumber,
    required String email,
    required String qualifications,
    required String gender,
    required double amount,
    required String language,
    String? avatarPath,
  }) async {
    try {
      final updateData = {
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'title': title.trim(),
        'specialty': specialty.trim(),
        'years_of_experience': yearsOfExperience,
        'phone_number': phoneNumber.trim(),
        'email': email.trim(),
        'qualifications': qualifications.trim(),
        'gender': gender.trim(),
        'amount': amount,
        'language': language.trim(),
        if (avatarPath != null && avatarPath.isNotEmpty)
          'avatar_path': avatarPath,
      };

      await _supabase
          .from('doctors')
          .update(updateData)
          .eq('id', doctorId);
    } catch (e) {
      throw Exception('Update failed: ${e.toString()}');
    }
  }

  Future<String?> uploadAvatar(String doctorId, String filePath) async {
    try {
      // Validate file type
      final fileExt = filePath.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(fileExt)) {
        throw Exception('Only JPG/PNG images allowed');
      }

      final fileName = 'avatar-$doctorId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final storagePath = 'public/$fileName';

      await _supabase.storage
          .from('Doctor Avatars')
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