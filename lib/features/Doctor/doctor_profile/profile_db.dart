import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // Add this import

class ProfileDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getDoctorProfile(String doctorId) async {
    // ... existing code ...
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
      } else {
         response['avatar_url'] = null; // Ensure URL is null if path is missing
      }


      return response;
    } catch (e) {
      debugPrint('Failed to load profile: ${e.toString()}'); // Keep or remove debugPrint as needed
      throw Exception('Failed to load profile: ${e.toString()}');
    }
    // ... existing code ...
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
     // ... existing code ...
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
      debugPrint('Update failed: ${e.toString()}'); // Keep or remove debugPrint
      throw Exception('Update failed: ${e.toString()}');
    }
     // ... existing code ...
  }

  Future<String?> uploadAvatar(String doctorId, String filePath) async {
     // ... existing code ...
        try {
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
       debugPrint('Avatar upload failed: ${e.toString()}'); // Keep or remove debugPrint
      throw Exception('Avatar upload failed: ${e.toString()}');
    }
     // ... existing code ...
  }

  // Added method
  String getAvatarUrl(String path) {
     try {
        return _supabase.storage.from('Doctor Avatars').getPublicUrl(path);
     } catch (e) {
        debugPrint("Error getting public URL for path $path: $e");
        return ''; // Return empty string or handle error as needed
     }
  }
}