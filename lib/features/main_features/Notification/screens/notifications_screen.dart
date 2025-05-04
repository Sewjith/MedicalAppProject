import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../models/notification_model.dart';
import '../widgets/notification_title.dart';

class NotificationsScreen extends StatefulWidget {
  final String receiverId;
  final String receiverType;

  const NotificationsScreen({
    Key? key,
    required this.receiverId,
    required this.receiverType,
  }) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  List<NotificationItem> notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();

    _service.listenToNotifications(
      receiverId: widget.receiverId,
      receiverType: widget.receiverType,
      onNewNotification: (item) {
        setState(() {
          notifications.insert(0, item);
        });
      },
    );
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await _service.fetchNotifications(
        receiverId: widget.receiverId,
        receiverType: widget.receiverType,
      );
      setState(() {
        notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load notifications: $e")),
      );
    }
  }

  Future<void> _markAsRead(NotificationItem item) async {
    try {
      await _service.markAsRead(item.id);
      setState(() {
        item.isRead = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to mark as read: $e")),
      );
    }
  }

  Future<void> _deleteNotification(NotificationItem item) async {
    try {
      await _service.deleteNotification(item.id);
      setState(() {
        notifications.remove(item);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification deleted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete notification: $e")),
      );
    }
  }

  Future<void> _deleteAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content:
            const Text("Are you sure you want to delete all notifications?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteAllNotifications(
            widget.receiverType, widget.receiverId);
        setState(() {
          notifications.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All notifications deleted")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete all notifications: $e")),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _service.markAllAsRead(widget.receiverType, widget.receiverId);
      setState(() {
        for (var notification in notifications) {
          notification.isRead = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All notifications marked as read")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to mark all as read: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
              color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete all notifications',
            onPressed: _deleteAllNotifications,
          ),
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text("Mark all",
                style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    "No notifications yet",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return Dismissible(
                      key: Key(item.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (_) => _deleteNotification(item),
                      child: NotificationTile(
                        item: item,
                        onTap: () => _markAsRead(item),
                      ),
                    );
                  },
                ),
    );
  }
}
