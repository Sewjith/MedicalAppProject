import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../widgets/notification_title.dart';
import '../models/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> notifications = [
    NotificationItem(title: "Scheduled Appointment", description: "Your appointment is confirmed.", timeAgo: "2M", dateGroup: "Today", icon: Icons.calendar_today),
    NotificationItem(title: "Scheduled Change", description: "Appointment rescheduled.", timeAgo: "2H", dateGroup: "Today", icon: Icons.calendar_today),
    NotificationItem(title: "Medical Notes", description: "New medical notes have been added.", timeAgo: "3H", dateGroup: "Today", icon: Icons.note),
    NotificationItem(title: "Prescription Ready", description: "Your prescription is ready.", timeAgo: "4H", dateGroup: "Today", icon: Icons.medical_services, isRead: true),
    NotificationItem(title: "Test Result Available", description: "Test results are now available.", timeAgo: "5H", dateGroup: "Today", icon: Icons.file_copy),
    NotificationItem(title: "Doctor Message", description: "You received a message from Dr. Smith.", timeAgo: "6H", dateGroup: "Today", icon: Icons.message, isRead: true),
    NotificationItem(title: "Diet Plan Sent", description: "New diet plan has been shared.", timeAgo: "7H", dateGroup: "Today", icon: Icons.fastfood),
    NotificationItem(title: "Reminder: Water Intake", description: "Stay hydrated!", timeAgo: "8H", dateGroup: "Today", icon: Icons.local_drink, isRead: true),
    NotificationItem(title: "Blood Pressure Log", description: "Time to log your BP.", timeAgo: "9H", dateGroup: "Yesterday", icon: Icons.favorite),
    NotificationItem(title: "Follow-up Reminder", description: "Reminder for follow-up checkup.", timeAgo: "10H", dateGroup: "Yesterday", icon: Icons.notifications),
    NotificationItem(title: "Vaccination Alert", description: "Scheduled vaccination tomorrow.", timeAgo: "11H", dateGroup: "Yesterday", icon: Icons.vaccines),
    NotificationItem(title: "Health Tips", description: "Daily health tips inside.", timeAgo: "12H", dateGroup: "Yesterday", icon: Icons.health_and_safety),
    NotificationItem(title: "New Report", description: "Your health report is uploaded.", timeAgo: "13H", dateGroup: "Yesterday", icon: Icons.insert_drive_file, isRead: true),
    NotificationItem(title: "Fitness Goal Achieved", description: "You’ve reached your weekly goal!", timeAgo: "14H", dateGroup: "Yesterday", icon: Icons.emoji_events),
    NotificationItem(title: "New Chat Message", description: "Support replied to your question.", timeAgo: "15H", dateGroup: "2 Days Ago", icon: Icons.chat),
    NotificationItem(title: "Payment Received", description: "Your payment has been processed.", timeAgo: "16H", dateGroup: "2 Days Ago", icon: Icons.payment, isRead: true),
    NotificationItem(title: "Appointment Feedback", description: "Leave feedback for your doctor.", timeAgo: "17H", dateGroup: "2 Days Ago", icon: Icons.feedback),
    NotificationItem(title: "Insurance Updated", description: "Your insurance info is updated.", timeAgo: "18H", dateGroup: "2 Days Ago", icon: Icons.security),
    NotificationItem(title: "App Update Available", description: "New version of the app is live.", timeAgo: "19H", dateGroup: "2 Days Ago", icon: Icons.system_update),
    NotificationItem(title: "Session Reminder", description: "Don’t forget your session today.", timeAgo: "20H", dateGroup: "2 Days Ago", icon: Icons.access_time),
  ];

  List<NotificationItem> _backupNotifications = [];

  Map<String, List<NotificationItem>> groupByDate(List<NotificationItem> items) {
    Map<String, List<NotificationItem>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.dateGroup, () => []);
      grouped[item.dateGroup]!.add(item);
    }
    return grouped;
  }

  void _deleteAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete All Notifications"),
        content: Text("Are you sure you want to delete all notifications?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _backupNotifications = List.from(notifications);
        notifications.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Notifications deleted"),
          action: SnackBarAction(
            label: "Undo",
            onPressed: () {
              setState(() {
                notifications = List.from(_backupNotifications);
              });
            },
          ),
        ),
      );
    }
  }

  void _markAllAsRead() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Mark All as Read"),
        content: Text("Are you sure you want to mark all notifications as read?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Yes")),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        for (var notification in notifications) {
          notification.isRead = true;
        }
      });
    }
  }

  void _openNotificationDetails(NotificationItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.blue),
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              item.title,
              style: TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text(item.description),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = groupByDate(notifications);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Notifications", style: TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete all notifications',
            onPressed: _deleteAllNotifications,
          ),
          TextButton(
            onPressed: _markAllAsRead,
            child: Text("Mark all", style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(child: Text("No notifications", style: TextStyle(fontSize: 16, color: Colors.grey)))
          : ListView(
        padding: EdgeInsets.all(16),
        children: groupedNotifications.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...entry.value.map((item) => Dismissible(
                key: ValueKey(item.title + item.timeAgo),
                background: Container(
                  padding: EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  color: Colors.red,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.startToEnd,
                onDismissed: (direction) {
                  setState(() {
                    notifications.remove(item);
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      item.isRead = true;
                    });
                    _openNotificationDetails(item);
                  },
                  child: Card(
                    color: item.isRead ? Colors.blue[50] : Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        radius: 22,
                        child: Icon(item.icon, color: Colors.blue, size: 20),
                      ),
                      title: Text(item.title, style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(item.timeAgo),
                      trailing: item.isRead ? null : Icon(Icons.fiber_manual_record, size: 10, color: Colors.red),
                    ),

                  ),
                ),
              )),
              SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
