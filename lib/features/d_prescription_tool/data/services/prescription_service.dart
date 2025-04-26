import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine_models.dart';

class PrescriptionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  // Fetch available medicines
  Future<List<SupabaseMedicine>> fetchMedicines() async {
    try {
      final response = await _supabase
          .from('medicines')
          .select('id, name, type')
          .order('name', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((map) => SupabaseMedicine.fromMap(map)).toList();
    } catch (e) {
      print('Supabase fetch medicine error: $e');
      throw Exception('Failed to fetch medicines: $e');
    }
  }

  // Add a new medicine
  Future<void> addNewMedicine(String name, String? type) async {
    try {
      await _supabase.from('medicines').insert({
        'name': name,
        if (type != null && type.isNotEmpty) 'type': type,
      });
    } catch (e) {
      print('Supabase add medicine error: $e');
      throw Exception('Failed to add medicine: $e');
    }
  }

  // Edit an existing medicine
  Future<void> editMedicine(
      String medicineId, String newName, String? newType) async {
    try {
      await _supabase.from('medicines').update({
        'name': newName,
        'type': newType,
      }).eq('id', medicineId);
    } catch (e) {
      print('Supabase edit medicine error: $e');
      throw Exception('Failed to update medicine: $e');
    }
  }

  // Delete a medicine
  Future<void> deleteMedicine(String medicineId) async {
    try {
      await _supabase.from('medicines').delete().eq('id', medicineId);
    } catch (e) {
      print('Supabase delete medicine error: $e');
      throw Exception('Failed to delete medicine: $e');
    }
  }

  // Submit the prescription
  Future<void> submitPrescription({
    required String appointmentId,
    required String patientId,
    required List<SelectedMedicine> selectedMedicines,
    String? notes,
  }) async {
    if (selectedMedicines.isEmpty) {
      throw Exception("Cannot submit an empty prescription.");
    }

    try {
      // Create prescription record
      final String uniquePrescriptionIdentifier =
          'PRES-${DateTime.now().millisecondsSinceEpoch}-${_uuid.v4().substring(0, 8)}';
      final prescriptionInsertResponse = await _supabase
          .from('prescriptions')
          .insert({
            'prescription_id': uniquePrescriptionIdentifier,
            'appointment_id': appointmentId,
            'patient_id': patientId,
            'notes': notes ?? '',
            'date_issued': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();
      final String newPrescriptionUUID = prescriptionInsertResponse['id'];

      // Prepare prescription medicine records
      final List<Map<String, dynamic>> prescriptionMedicinesData =
          selectedMedicines.map((med) {
        return {
          'prescription_id': newPrescriptionUUID,
          'medicine_id': med.medicineId,
          'dosage': med.dosage,
          'frequency': med.frequency,
          'duration': med.duration,
          'notes': med.instructions,
        };
      }).toList();

      // Insert into supabase table
      await _supabase
          .from('prescription_medicines')
          .insert(prescriptionMedicinesData);
    } catch (e) {
      print('Supabase submit prescription error: $e');
      throw Exception('Failed to submit prescription: $e');
    }
  }
}
