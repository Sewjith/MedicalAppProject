import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:intl/intl.dart'; 
import 'notification_item.dart';

class NotificationService {
  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _notificationChannel; 

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

    
    String channelName = 'public:notifications'; 
    print('Attempting to subscribe to channel: $channelName');

    _notificationChannel = _client.channel(channelName);

    _notificationChannel!
      .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            print('Realtime Notification Payload Received: ${payload.toString()}');
            if (payload.newRecord != null) {
              final newItem = payload.newRecord!;
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
                  print("Filtered out notification for different receiver/type: ID ${newItem['receiver_id']}, Type ${newItem['receiver_type']}");
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
      print('Unsubscribing from notification channel...');
      try {
        _client.removeChannel(_notificationChannel!);
        _notificationChannel = null; 
        print('Successfully unsubscribed.');
      } catch (e) {
         print('Error unsubscribing from channel: $e');
      }
    }
  }

  void dispose() {
    _unsubscribeFromNotifications(); 
  }

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
        print("Error marking as read (ID: $id): $e");
     }
  }

  Future<void> markAsUnread(String id) async {
     try {
      await _client.from('notifications').update({'read_status': false}).eq('id', id);
     } catch (e) {
        print("Error marking as unread (ID: $id): $e");
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
      print("Error deleting notification (ID: $id): $e");
    }
  }

  Future<void> restoreNotification(NotificationItem item) async {
    try {
      await _client.from('notifications').insert({
        'id': item.id, 
        'receiver_id': 'patient-id-here', 
        'receiver_type': 'patient', 
        'message': item.title,
        'reference_type': item.description,
        'type': 'appointment_reminder', 
        'read_status': item.isRead,
        'created_at': DateTime.now().toIso8601String(), 
      });
    } catch (e) {
       print("Error restoring notification (ID: ${item.id}): $e");
    }
  }



  String _formatTimeAgo(String? timestamp) {
     if (timestamp == null) return '';
     try {
        final created = DateTime.parse(timestamp).toLocal(); 
        final now = DateTime.now();
        final diff = now.difference(created);

        if (diff.inMinutes < 1) return 'now';
        if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
        if (diff.inHours < 24) return '${diff.inHours}h ago';
        if (diff.inDays < 7) return '${diff.inDays}d ago';
        return DateFormat('MMM d').format(created);
     } catch (e) {
        print("Error formatting time ago for '$timestamp': $e");
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
        print("Error formatting date group for '$timestamp': $e");
        return 'Invalid Date';
     }
  }

  IconData _getIconFromType(String? type) {
    switch (type?.toLowerCase()) {
      case 'appointment_reminder': 
        return Icons.calendar_today_outlined;
      case 'message':
        return Icons.message_outlined;
      case 'reminder':
        return Icons.notifications_active_outlined;
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'symptom': 
        return Icons.monitor_heart_outlined;
      default:
        return Icons.info_outline; 
    }
  }
}