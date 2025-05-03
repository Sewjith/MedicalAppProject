import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Ensure imported
import 'package:intl/intl.dart'; // Import for date formatting
import 'notification_item.dart';

class NotificationService {
  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _notificationChannel; // Store channel reference

  Future<List<NotificationItem>> fetchNotifications({
    required String receiverType,
    required String receiverId,
  }) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('receiver_type', receiverType)
          .eq('receiver_id', receiverId)
          .order('created_at', ascending: false);

      return (response).map((item) {
        return NotificationItem(
          id: item['id'] ?? UniqueKey().toString(),
          title: item['message'] ?? 'No title',
          description: item['reference_type'] ?? '',
          timeAgo: _formatTimeAgo(item['created_at']),
          dateGroup: _formatDateGroup(item['created_at']),
          icon: _getIconFromType(item['type']),
          isRead: item['read_status'] ?? false,
        );
      }).toList();
    } catch (e) {
       print("Error fetching notifications: $e");
       return [];
    }
  }

  void listenToNotifications({
    required String receiverType,
    required String receiverId,
    required void Function(NotificationItem) onNewNotification,
  }) {
    _unsubscribeFromNotifications();

    // Define channel name (make it specific if possible)
    // Note: Filtering usually happens server-side or client-side in the callback
    String channelName = 'public:notifications:receiver_id=eq.$receiverId'; // Example channel name
    print('Attempting to subscribe to channel: $channelName');

    _notificationChannel = _client.channel(channelName);

    _notificationChannel!
      .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          // Filter on the client side or rely on RLS/channel name for server-side filtering
          callback: (payload) {
            print('Realtime Notification Payload Received: ${payload.toString()}');
            if (payload.newRecord != null) {
              final newItem = payload.newRecord!;
              // Check if the notification is for the correct user
              if (newItem['receiver_type'] == receiverType && newItem['receiver_id'] == receiverId) {
                 onNewNotification(
                   NotificationItem(
                     id: newItem['id'] ?? UniqueKey().toString(),
                     title: newItem['message'] ?? 'No title',
                     description: newItem['reference_type'] ?? '',
                     timeAgo: _formatTimeAgo(newItem['created_at']),
                     dateGroup: _formatDateGroup(newItem['created_at']),
                     icon: _getIconFromType(newItem['type']),
                     isRead: newItem['read_status'] ?? false,
                   ),
                 );
               } else {
                  print("Filtered out notification for different receiver: ${newItem['receiver_id']}");
               }
            } else {
              print("Received Realtime payload without newRecord: ${payload.eventType}");
            }
          })
      .subscribe(
          (status, [error]) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              print('Successfully subscribed to notification channel: $channelName');
            } else {
              print('Notification subscription failed for $channelName: Status $status, Error: $error');
            }
          },
       );
  }

  void _unsubscribeFromNotifications() {
    if (_notificationChannel != null) {
       // *** FIX: Removed .channelName as it doesn't exist ***
      print('Unsubscribing from notification channel...');
      _client.removeChannel(_notificationChannel!);
      _notificationChannel = null;
    }
  }

  void dispose() {
    _unsubscribeFromNotifications();
  }

 // --- Rest of the methods ---
  Future<void> markAllAsRead(String receiverType, String receiverId) async {
     try {
       await _client
           .from('notifications')
           .update({'read_status': true})
           .eq('receiver_type', receiverType)
           .eq('receiver_id', receiverId)
           .eq('read_status', false);
     } catch (e) {
        print("Error marking all as read: $e");
     }
  }

  Future<void> markAsRead(String id) async {
     try {
       await _client.from('notifications').update({'read_status': true}).eq('id', id);
     } catch (e) {
        print("Error marking as read: $e");
     }
  }

  Future<void> markAsUnread(String id) async {
     try {
      await _client.from('notifications').update({'read_status': false}).eq('id', id);
     } catch (e) {
        print("Error marking as unread: $e");
     }
  }

  Future<void> deleteAllNotifications(String receiverType, String receiverId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('receiver_type', receiverType)
          .eq('receiver_id', receiverId);
    } catch (e) {
       print("Error deleting all notifications: $e");
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _client.from('notifications').delete().eq('id', id);
    } catch (e) {
      print("Error deleting notification: $e");
    }
  }

  Future<void> restoreNotification(NotificationItem item) async {
    try {
      await _client.from('notifications').insert({
        'message': item.title,
        'reference_type': item.description,
        'receiver_type': 'patient', // Example: Determine type dynamically if needed
        'receiver_id': 'abc-123', // Example: Need actual receiver ID
        'type': 'message', // Example: Determine type dynamically
        'read_status': item.isRead,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
       print("Error restoring notification: $e");
    }
  }

  String _formatTimeAgo(String? timestamp) {
     if (timestamp == null) return '';
     try {
        final created = DateTime.parse(timestamp).toLocal();
        final now = DateTime.now();
        final diff = now.difference(created);
        if (diff.inMinutes < 1) return 'now';
        if (diff.inMinutes < 60) return '${diff.inMinutes}m';
        if (diff.inHours < 24) return '${diff.inHours}h';
        return '${diff.inDays}d';
     } catch (e) {
        return '';
     }
  }

  String _formatDateGroup(String? timestamp) {
     if (timestamp == null) return 'Unknown Date';
     try {
        final date = DateTime.parse(timestamp).toLocal();
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));
        final dateOnly = DateTime(date.year, date.month, date.day);

        if (dateOnly == today) return 'Today';
        if (dateOnly == yesterday) return 'Yesterday';
        return DateFormat('MMM d, yyyy').format(date);
     } catch (e) {
        return 'Invalid Date';
     }
  }

  IconData _getIconFromType(String? type) {
    switch (type?.toLowerCase()) {
      case 'message':
        return Icons.message_outlined;
      case 'reminder':
        return Icons.notifications_active_outlined;
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'symptom':
        return Icons.monitor_heart_outlined;
      case 'appointment':
        return Icons.calendar_today_outlined;
      default:
        return Icons.info_outline;
    }
  }
}