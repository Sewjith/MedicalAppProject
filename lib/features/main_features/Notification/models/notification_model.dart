//@annotate:modification:lib/features/main_features/Notification/models/notification_model.dart
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
          icon: _getIconFromType(item['type']), // Use helper to get icon
          isRead: item['read_status'] ?? false,
        );
      }).toList();
    } catch (e) {
       print("Error fetching notifications: $e");
       // Return empty list or rethrow based on desired error handling
       return [];
       // throw Exception("Failed to fetch notifications: $e");
    }
  }

   void listenToNotifications({
    required String receiverType,
    required String receiverId,
    required void Function(NotificationItem) onNewNotification,
  }) {
    _unsubscribeFromNotifications(); // Ensure only one subscription

    // Define channel name (make it specific if possible)
    // RLS (Row Level Security) on the Supabase table is the most secure way
    // to ensure users only get their own notifications.
    // Client-side filtering (as done below) is a backup but not fully secure.
    String channelName = 'public:notifications'; // Generic channel
    print('Attempting to subscribe to channel: $channelName');

    _notificationChannel = _client.channel(channelName);

    _notificationChannel!
      .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          // Filter on the client side (less secure than RLS)
          callback: (payload) {
            print('Realtime Notification Payload Received: ${payload.toString()}');
            if (payload.newRecord != null) {
              final newItem = payload.newRecord!;
              // Check if the notification is for the correct user AND type
              if (newItem['receiver_type'] == receiverType && newItem['receiver_id'] == receiverId) {
                 onNewNotification(
                   NotificationItem(
                     id: newItem['id'] ?? UniqueKey().toString(),
                     title: newItem['message'] ?? 'No title',
                     description: newItem['reference_type'] ?? '',
                     timeAgo: _formatTimeAgo(newItem['created_at']),
                     dateGroup: _formatDateGroup(newItem['created_at']),
                     icon: _getIconFromType(newItem['type']), // Use helper
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
              // Handle subscription error (e.g., retry, notify user)
            }
          },
           // Optional: Timeout duration
          // timeout: const Duration(seconds: 10),
       );
  }


  void _unsubscribeFromNotifications() {
    if (_notificationChannel != null) {
      print('Unsubscribing from notification channel...');
      try {
        // Use removeChannel, not removeSubscription directly on the channel instance
        _client.removeChannel(_notificationChannel!);
        _notificationChannel = null; // Set to null after removal
        print('Successfully unsubscribed.');
      } catch (e) {
         print('Error unsubscribing from channel: $e');
      }
    }
  }

  void dispose() {
    _unsubscribeFromNotifications(); // Clean up subscription on dispose
  }

  // Mark all as read
  Future<void> markAllAsRead(String receiverType, String receiverId) async {
     try {
       await _client
           .from('notifications')
           .update({'read_status': true})
           .eq('receiver_type', receiverType)
           .eq('receiver_id', receiverId)
           .eq('read_status', false); // Only update unread ones
     } catch (e) {
        print("Error marking all as read: $e");
        // Handle error appropriately
     }
  }

  // Mark specific notification as read
  Future<void> markAsRead(String id) async {
     try {
       await _client.from('notifications').update({'read_status': true}).eq('id', id);
     } catch (e) {
        print("Error marking as read (ID: $id): $e");
     }
  }

  // Mark specific notification as unread
  Future<void> markAsUnread(String id) async {
     try {
      await _client.from('notifications').update({'read_status': false}).eq('id', id);
     } catch (e) {
        print("Error marking as unread (ID: $id): $e");
     }
  }

   // Delete all notifications for a user
  Future<void> deleteAllNotifications(String receiverType, String receiverId) async {
    try {
      await _client
          .from('notifications')
          .delete()
          .eq('receiver_type', receiverType)
          .eq('receiver_id', receiverId);
    } catch (e) {
       print("Error deleting all notifications: $e");
       // Handle error
    }
  }

  // Delete a specific notification
  Future<void> deleteNotification(String id) async {
    try {
      await _client.from('notifications').delete().eq('id', id);
    } catch (e) {
      print("Error deleting notification (ID: $id): $e");
      // Handle error
    }
  }

  // Restore a notification (for Undo functionality - simplistic example)
  // Note: This is a basic example; a real undo might need a "deleted" flag instead.
  Future<void> restoreNotification(NotificationItem item) async {
    try {
      // Re-insert the notification data. Adjust payload as needed.
      await _client.from('notifications').insert({
        'id': item.id, // May cause issues if ID is auto-generated differently
        'receiver_id': 'patient-id-here', // Needs actual receiver ID
        'receiver_type': 'patient', // Needs actual receiver type
        'message': item.title,
        'reference_type': item.description,
        'type': 'appointment_reminder', // Example, determine actual type
        'read_status': item.isRead,
        'created_at': DateTime.now().toIso8601String(), // Or use original timestamp?
        // Add other necessary fields like reference_id
      });
    } catch (e) {
       print("Error restoring notification (ID: ${item.id}): $e");
       // Handle error
    }
  }


  // --- Helper Methods ---

  String _formatTimeAgo(String? timestamp) {
     if (timestamp == null) return '';
     try {
        final created = DateTime.parse(timestamp).toLocal(); // Convert to local time
        final now = DateTime.now();
        final diff = now.difference(created);

        if (diff.inMinutes < 1) return 'now';
        if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
        if (diff.inHours < 24) return '${diff.inHours}h ago';
        if (diff.inDays < 7) return '${diff.inDays}d ago';
        // Optionally return date for older notifications
        return DateFormat('MMM d').format(created);
     } catch (e) {
        print("Error formatting time ago for '$timestamp': $e");
        return ''; // Return empty or placeholder on error
     }
  }

  String _formatDateGroup(String? timestamp) {
     if (timestamp == null) return 'Unknown Date';
     try {
        final date = DateTime.parse(timestamp).toLocal(); // Use local time
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));
        final dateOnly = DateTime(date.year, date.month, date.day);

        if (dateOnly == today) return 'Today';
        if (dateOnly == yesterday) return 'Yesterday';
        // For older dates, include the year
        return DateFormat('MMM d, yyyy').format(date); // e.g., Aug 15, 2024
     } catch (e) {
        print("Error formatting date group for '$timestamp': $e");
        return 'Invalid Date';
     }
  }

  // Helper to map notification type string to an IconData
  IconData _getIconFromType(String? type) {
    switch (type?.toLowerCase()) {
      case 'appointment_reminder': // Handle the new type
        return Icons.calendar_today_outlined;
      case 'message':
        return Icons.message_outlined;
      case 'reminder':
        return Icons.notifications_active_outlined;
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'symptom': // Example for symptom tracker
        return Icons.monitor_heart_outlined;
      // Add more cases as needed
      default:
        return Icons.info_outline; // Default icon
    }
  }
}