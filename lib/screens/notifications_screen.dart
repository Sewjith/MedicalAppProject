import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<NotificationItem> notifications = [];
  List<NotificationItem> _backupNotifications = [];

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
        _playNotificationSound();
      },
    );
  }

  Future<void> _playNotificationSound() async {
    await _audioPlayer.play(AssetSource('audio/ding.mp3'));
  }

  Future<void> _loadNotifications() async {
    final data = await _service.fetchNotifications(
      receiverId: widget.receiverId,
      receiverType: widget.receiverType,
    );
    setState(() => notifications = data);
  }

  Future<void> _markAsRead(NotificationItem item) async {
    await _service.markAsRead(item.id);
    setState(() {
      item.isRead = true;
    });
  }

  Future<void> _markAsUnread(NotificationItem item) async {
    await _service.markAsUnread(item.id);
    setState(() {
      item.isRead = false;
    });
  }

  Future<void> _deleteNotification(NotificationItem item) async {
    setState(() {
      notifications.remove(item);
    });

    await _service.deleteNotification(item.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Notification deleted"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () async {
            await _service.restoreNotification(item);
            setState(() => notifications.insert(0, item));
          },
        ),
      ),
    );
  }

  Future<void> _deleteAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete All Notifications"),
        content: const Text("Are you sure you want to delete all notifications?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      _backupNotifications = List.from(notifications);

      await _service.deleteAllNotifications(widget.receiverType, widget.receiverId);
      setState(() => notifications.clear());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("All notifications deleted"),
          action: SnackBarAction(
            label: "Undo",
            onPressed: () async {
              for (var item in _backupNotifications) {
                await _service.restoreNotification(item);
              }
              _loadNotifications();
            },
          ),
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Mark All as Read"),
        content: const Text("Are you sure you want to mark all notifications as read?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );

    if (confirm == true) {
      await _service.markAllAsRead(widget.receiverType, widget.receiverId);
      setState(() {
        for (var item in notifications) {
          item.isRead = true;
        }
      });
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
          style: TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete all notifications',
            onPressed: _deleteAllNotifications,
          ),
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text("Mark all", style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("No notifications yet"))
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
            child: GestureDetector(
              onTap: () => _markAsRead(item),
              onLongPress: () => _markAsUnread(item),
              child: NotificationTile(item: item, onTap: () {}),
            ),
          );
        },
      ),
    );
  }
}
