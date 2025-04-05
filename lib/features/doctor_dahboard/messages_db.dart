import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMessages() async {
    final response = await _supabase
        .from('messages')
        .select('sender_name, content, created_at, is_read')
        .order('created_at', ascending: false);
    return response;
  }

  Future<void> markAsRead(String messageId) async {
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('id', messageId);
  }
}