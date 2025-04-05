import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class HealthRecordBackend {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _patientId = "a0945ec7-b0b8-4672-95a7-29b6da1b6587";
  final Uuid _uuid = const Uuid();

  Future<List<Map<String, dynamic>>> getHealthRecords({
    bool favoritesOnly = false,
    String? category,
  }) async {
    try {
      var query = _supabase
          .from('health_records')
          .select()
          .eq('patient_id', _patientId);

      if (favoritesOnly) {
        query = query.eq('is_favourite', true);
      }

      if (category != null) {
        query = query.eq('category', category);
      }

      final response = await query.order('record_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching records: $e');
      throw Exception('Failed to fetch records: ${e.toString()}');
    }
  }

  Future<void> addHealthRecord({
    required String title,
    required String category,
    required String type,
    required String level,
    String? description,
    DateTime? recordDate,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      await _supabase.from('health_records').insert({
        'id': _uuid.v4(),
        'record_id': _uuid.v4().substring(0, 8), 
        'patient_id': _patientId,
        'title': title,
        'description': description,
        'type': type,
        'category': category,
        'level': level,
        'record_date': recordDate?.toUtc().toIso8601String() ?? now.toIso8601String(),
        'is_favourite': false,
        'created_at': now.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Add record error: $e');
      throw Exception('Failed to add record: ${e.toString()}');
    }
  }

  Future<void> toggleFavorite(String recordId) async {
    try {
      final current = await _supabase
          .from('health_records')
          .select('is_favourite')
          .eq('id', recordId)
          .single();

      await _supabase
          .from('health_records')
          .update({'is_favourite': !(current['is_favourite'] as bool)})
          .eq('id', recordId);
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
      throw Exception('Failed to toggle favorite: ${e.toString()}');
    }
  }

  Future<void> deleteRecord(String recordId) async {
    try {
      await _supabase.from('health_records').delete().eq('id', recordId);
    } catch (e) {
      debugPrint('Delete error: $e');
      throw Exception('Failed to delete record: ${e.toString()}');
    }
  }

  Future<void> updateRecord({
    required String id,
    String? title,
    String? description,
    String? category,
    String? type,
    String? level,
    DateTime? recordDate,
  }) async {
    try {
      await _supabase.from('health_records').update({
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (type != null) 'type': type,
        if (level != null) 'level': level,
        if (recordDate != null) 'record_date': recordDate.toUtc().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      debugPrint('Update error: $e');
      throw Exception('Failed to update record: ${e.toString()}');
    }
  }
}