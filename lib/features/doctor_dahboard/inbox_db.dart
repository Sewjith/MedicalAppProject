import 'package:supabase_flutter/supabase_flutter.dart';

class InboxDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMessages() async {
    try {
      final response = await _supabase
          .from('messages')
          .select('patient_id, sender_name, content, created_at')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }


  Future<Map<String, List<Map<String, dynamic>>>> getGroupedMessages() async {
    try {
      final messages = await getMessages();
      final groupedMessages = <String, List<Map<String, dynamic>>>{};

      for (var message in messages) {
        final sender = message['sender_name'] ?? 'Unknown';
        if (!groupedMessages.containsKey(sender)) {
          groupedMessages[sender] = [];
        }
        groupedMessages[sender]!.add(message);
      }

      return groupedMessages;
    } catch (e) {
      throw Exception('Failed to group messages: $e');
    }
  }
}