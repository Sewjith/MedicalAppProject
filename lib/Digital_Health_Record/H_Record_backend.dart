import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

class HealthRecordBackend {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _patientId =
      "a0945ec7-b0b8-4672-95a7-29b6da1b6587"; // Replace with actual patient ID
  final Uuid _uuid = const Uuid();
  final String _bucketName = 'healthrecords';

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

  Future<String?> _uploadFile(File file) async {
    try {
      final fileExt = path.extension(file.path);
      final fileName = '${_uuid.v4()}$fileExt';
      final fileBytes = await file.readAsBytes();
      final mimeType = lookupMimeType(file.path);

      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(fileName, fileBytes,
              fileOptions: FileOptions(
                contentType: mimeType,
                upsert: false,
              ));

      return _supabase.storage.from(_bucketName).getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  Future<void> addHealthRecord({
    required String title,
    required String category,
    required String type,
    required String level,
    String? description,
    required DateTime recordDate,
    File? attachment,
  }) async {
    try {
      final now = DateTime.now().toUtc();
      final recordId = _uuid.v4();

      // Upload attachment if exists
      String? docLink;
      if (attachment != null) {
        docLink = await _uploadFile(attachment);
      }

      await _supabase.from('health_records').insert({
        'id': recordId,
        'record_id': _uuid.v4().substring(0, 8),
        'patient_id': _patientId,
        'title': title,
        'description': description,
        'type': type,
        'category': category,
        'level': level,
        'doc_link': docLink,
        'record_date': recordDate.toUtc().toIso8601String(),
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
          .update({'is_favourite': !(current['is_favourite'] as bool)}).eq(
              'id', recordId);
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
      throw Exception('Failed to toggle favorite: ${e.toString()}');
    }
  }

  Future<void> deleteRecord(String recordId) async {
    try {
      // First get the record to check for doc_link
      final record = await _supabase
          .from('health_records')
          .select('doc_link')
          .eq('id', recordId)
          .single();

      // Delete attachment if exists
      final docLink = record['doc_link'] as String?;
      if (docLink != null) {
        final fileName = path.basename(docLink);
        await _supabase.storage.from(_bucketName).remove([fileName]);
      }

      // Delete the record
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
    File? newAttachment,
    bool? removeAttachment,
  }) async {
    try {
      // Get current record data
      final currentRecord = await _supabase
          .from('health_records')
          .select('doc_link')
          .eq('id', id)
          .single();

      String? currentDocLink = currentRecord['doc_link'];
      String? newDocLink;

      // Handle attachment removal
      if (removeAttachment == true && currentDocLink != null) {
        final fileName = path.basename(currentDocLink);
        await _supabase.storage.from(_bucketName).remove([fileName]);
        currentDocLink = null;
      }

      // Handle new attachment upload
      if (newAttachment != null) {
        // Delete old attachment if exists
        if (currentDocLink != null) {
          final fileName = path.basename(currentDocLink);
          await _supabase.storage.from(_bucketName).remove([fileName]);
        }

        newDocLink = await _uploadFile(newAttachment);
      }

      // Update the record
      await _supabase.from('health_records').update({
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (type != null) 'type': type,
        if (level != null) 'level': level,
        if (recordDate != null)
          'record_date': recordDate.toUtc().toIso8601String(),
        'doc_link':
            newDocLink ?? (removeAttachment == true ? null : currentDocLink),
      }).eq('id', id);
    } catch (e) {
      debugPrint('Update error: $e');
      throw Exception('Failed to update record: ${e.toString()}');
    }
  }
}
