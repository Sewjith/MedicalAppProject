import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class DoctorPatientNotesDB {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();


  Future<List<Map<String, dynamic>>> getPatientNotes({
    required String doctorId,
    required String patientId,
  }) async {
    if (doctorId.isEmpty || patientId.isEmpty) {
      throw Exception('Doctor ID and Patient ID cannot be empty.');
    }
    try {
      final response = await _supabase
          .from('doctor_patient_notes')
          .select()
          .eq('doctor_id', doctorId)
          .eq('patient_id', patientId)
          .order('created_at', ascending: false); 

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching patient notes: $e');
      throw Exception('Failed to fetch patient notes: ${e.toString()}');
    }
  }

  
  Future<void> addPatientNote({
    required String doctorId,
    required String patientId,
    required String noteContent,
    String? appointmentId, 
  }) async {
    if (doctorId.isEmpty || patientId.isEmpty || noteContent.trim().isEmpty) {
      throw Exception('Doctor ID, Patient ID, and Note Content are required.');
    }
    try {
      await _supabase.from('doctor_patient_notes').insert({
        'note_id': _uuid.v4(), // Generate new UUID for the note
        'patient_id': patientId,
        'doctor_id': doctorId,
        'appointment_id': appointmentId, // Can be null
        'note_content': noteContent.trim(),

      });
    } catch (e) {
      debugPrint('Error adding patient note: $e');
      throw Exception('Failed to add patient note: ${e.toString()}');
    }
  }


  Future<void> updatePatientNote({
    required String noteId,
    required String doctorId, // To ensure the doctor owns the note
    required String updatedContent,
  }) async {
    if (noteId.isEmpty || doctorId.isEmpty || updatedContent.trim().isEmpty) {
      throw Exception('Note ID, Doctor ID, and Note Content are required.');
    }
    try {
      await _supabase
          .from('doctor_patient_notes')
          .update({
            'note_content': updatedContent.trim(),
            'updated_at': DateTime.now().toIso8601String(), // Explicitly set update time
          })
          .eq('note_id', noteId)
          .eq('doctor_id', doctorId); // Ensure only the owner can update

    } catch (e) {
      debugPrint('Error updating patient note: $e');
      throw Exception('Failed to update patient note: ${e.toString()}');
    }
  }

  Future<void> deletePatientNote({
    required String noteId,
    required String doctorId, // To ensure the doctor owns the note
  }) async {
    if (noteId.isEmpty || doctorId.isEmpty) {
      throw Exception('Note ID and Doctor ID are required.');
    }
    try {
      await _supabase
          .from('doctor_patient_notes')
          .delete()
          .eq('note_id', noteId)
          .eq('doctor_id', doctorId); // Ensure only the owner can delete

    } catch (e) {
      debugPrint('Error deleting patient note: $e');
      throw Exception('Failed to delete patient note: ${e.toString()}');
    }
  }


  Future<List<Map<String, dynamic>>> getDoctorPatientsList(String doctorId) async {
    if (doctorId.isEmpty) {
      throw Exception('Doctor ID cannot be empty.');
    }
    try {
      // Find unique patient IDs who had appointments with this doctor
      final appointmentResponse = await _supabase
          .from('appointments')
          .select('patient_id')
          .eq('doctor_id', doctorId);

      if (appointmentResponse.isEmpty) {
        return []; // No patients found through appointments
      }

      // Extract unique patient IDs
      final patientIds = appointmentResponse
          .map((appt) => appt['patient_id'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .toSet() // Get unique IDs
          .toList();

      if (patientIds.isEmpty) {
        return [];
      }


      final patientDetailsResponse = await _supabase
          .from('patients')
          .select('id, first_name, last_name, Age, gender') // Select needed fields
          .inFilter('id', patientIds)
          .order('last_name', ascending: true);
  

   
       for (var patient in patientDetailsResponse) {
         if (patient.containsKey('Age')) {
             patient['age'] = patient.remove('Age'); // Rename key for consistency
         }
         patient['avatar_url'] = null;

       }

      return List<Map<String, dynamic>>.from(patientDetailsResponse);

    } catch (e) {
      // Handle potential PostgrestExceptions specifically if needed
      if (e is PostgrestException) {
         debugPrint('Supabase Error fetching doctor patients list: ${e.message}, Code: ${e.code}');
         // Re-throw a more user-friendly message or the original exception
         throw Exception('Database error fetching patient list: ${e.message}');
      }
      debugPrint('Generic Error fetching doctor patients list: $e');
      throw Exception('Failed to fetch patient list: ${e.toString()}');
    }
  }

  /// Fetches detailed profile for a single patient.
  Future<Map<String, dynamic>> getPatientDetails(String patientId) async {
    if (patientId.isEmpty) {
      throw Exception('Patient ID cannot be empty.');
    }
    try {
      
      final response = await _supabase
          .from('patients')
          .select('id, patient_id, first_name, last_name, phone_number, email, date_of_birth, gender, address, password_hash, Age, is_deleted, created_at') // List all needed columns EXCEPT avatar_path
          .eq('id', patientId)
          .maybeSingle();


      if (response == null) {
        throw Exception('Patient not found.');
      }

       // Rename 'Age' key
       if (response.containsKey('Age')) {
           response['age'] = response.remove('Age');
       }

       response['avatar_url'] = null;
 
      return response;
    } catch (e) {
      debugPrint('Error fetching patient details: $e');
      throw Exception('Failed to fetch patient details: ${e.toString()}');
    }
  }

  /// Fetches appointment history for a specific patient with this doctor.
  Future<List<Map<String, dynamic>>> getPatientConsultationHistory({
    required String doctorId,
    required String patientId,
  }) async {
    if (doctorId.isEmpty || patientId.isEmpty) {
      throw Exception('Doctor ID and Patient ID cannot be empty.');
    }
    try {
      final response = await _supabase
          .from('appointments')
          .select('appointment_id, appointment_date, appointment_time, appointment_status, notes')
          .eq('doctor_id', doctorId)
          .eq('patient_id', patientId)
          .order('appointment_date', ascending: false)
          .order('appointment_time', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching patient consultation history: $e');
      throw Exception('Failed to fetch consultation history: ${e.toString()}');
    }
  }

  /// Fetches medical records for a specific patient.
  Future<List<Map<String, dynamic>>> getPatientMedicalHistory(String patientId) async {
     if (patientId.isEmpty) {
       throw Exception('Patient ID cannot be empty.');
     }
    try {
       final response = await _supabase
           .from('health_records')
           .select()
           .eq('patient_id', patientId)
           .order('record_date', ascending: false);
       return List<Map<String, dynamic>>.from(response);
    } catch (e) {
       debugPrint('Error fetching patient medical history: $e');
       throw Exception('Failed to fetch medical history: ${e.toString()}');
    }
  }
}
