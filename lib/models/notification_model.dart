import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_item.dart';

class NotificationService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<NotificationItem>> fetchNotifications({
    required String receiverType,
    required String receiverId,
  }) async {
    final response = await _client
        .from('notifications')
        .select()
        .eq('receiver_type', receiverType)
        .eq('receiver_id', receiverId)
        .order('created_at', ascending: false);

    return (response as List).map((item) {
      return NotificationItem(
        id: item['id'],
        title: item['message'] ?? 'No title',
        description: item['reference_type'] ?? '',
        timeAgo: _formatTimeAgo(item['created_at']),
        dateGroup: _formatDateGroup(item['created_at']),
        icon: _getIconFromType(item['type']),
        isRead: item['read_status'] ?? false,
      );
    }).toList();
  }

  void listenToNotifications({
    required String receiverType,
    required String receiverId,
    required void Function(NotificationItem) onNewNotification,
  }) {
    final channel = _client.channel('public:notifications');

    channel.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'INSERT',
        schema: 'public',
        table: 'notifications',
        filter: 'receiver_type=eq.$receiverType,receiver_id=eq.$receiverId',
      ),
          (payload, [ref]) {
        final newItem = payload['new'] as Map<String, dynamic>;
        onNewNotification(
          NotificationItem(
            id: newItem['id'],
            title: newItem['message'] ?? 'No title',
            description: newItem['reference_type'] ?? '',
            timeAgo: _formatTimeAgo(newItem['created_at']),
            dateGroup: _formatDateGroup(newItem['created_at']),
            icon: _getIconFromType(newItem['type']),
            isRead: newItem['read_status'] ?? false,
          ),
        );
      },
    );

    channel.subscribe();
  }

  Future<void> markAllAsRead(String receiverType, String receiverId) async {
    await _client
        .from('notifications')
        .update({'read_status': true})
        .eq('receiver_type', receiverType)
        .eq('receiver_id', receiverId);
  }

  Future<void> markAsRead(String id) async {
    await _client.from('notifications').update({'read_status': true}).eq('id', id);
  }

  Future<void> markAsUnread(String id) async {
    await _client.from('notifications').update({'read_status': false}).eq('id', id);
  }

  Future<void> deleteAllNotifications(String receiverType, String receiverId) async {
    await _client
        .from('notifications')
        .delete()
        .eq('receiver_type', receiverType)
        .eq('receiver_id', receiverId);
  }

  Future<void> deleteNotification(String id) async {
    await _client.from('notifications').delete().eq('id', id);
  }

  Future<void> restoreNotification(NotificationItem item) async {
    await _client.from('notifications').insert({
      'id': item.id,
      'message': item.title,
      'reference_type': item.description,
      'receiver_type': item.dateGroup == 'Today' ? 'patient' : 'doctor',
      'receiver_id': 'abc-123', // adjust if needed
      'type': 'message',
      'read_status': item.isRead,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  String _formatTimeAgo(String timestamp) {
    final created = DateTime.parse(timestamp).toLocal();
    final now = DateTime.now();
    final diff = now.difference(created);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  String _formatDateGroup(String timestamp) {
    final date = DateTime.parse(timestamp).toLocal();
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${date.month}/${date.day}/${date.year}';
  }

  IconData _getIconFromType(String? type) {
    switch (type) {
      case 'message':
        return Icons.message;
      case 'reminder':
        return Icons.notifications;
      case 'alert':
        return Icons.warning;
      case 'symptom':
        return Icons.health_and_safety;
      case 'appointment':
        return Icons.calendar_today;
      default:
        return Icons.info;
    }
  }
}
