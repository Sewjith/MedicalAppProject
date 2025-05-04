
// screens/notification_screen.dart
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
    NotificationItem(title: "Scheduled Appointment", description: "Lorem ipsum...", timeAgo: "2M", dateGroup: "Today", icon: Icons.calendar_today, id: ''),
    NotificationItem(title: "Scheduled Change", description: "Lorem ipsum...", timeAgo: "2H", dateGroup: "Today", icon: Icons.calendar_today, isRead: true, id: ''),
    NotificationItem(title: "Medical Notes", description: "Lorem ipsum...", timeAgo: "3H", dateGroup: "Today", icon: Icons.note, id: ''),
    NotificationItem(title: "Scheduled Appointment", description: "Lorem ipsum...", timeAgo: "1D", dateGroup: "Yesterday", icon: Icons.calendar_today, isRead: true, id: ''),
    NotificationItem(title: "Medical History Update", description: "Lorem ipsum...", timeAgo: "5D", dateGroup: "15 April", icon: Icons.chat_bubble_outline, id: ''),
  ];

  // Function to group notifications by date
  Map<String, List<NotificationItem>> groupByDate(List<NotificationItem> items) {
    Map<String, List<NotificationItem>> grouped = {};
    for (var item in items) {
      if (!grouped.containsKey(item.dateGroup)) {
        grouped[item.dateGroup] = [];
      }
      grouped[item.dateGroup]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = groupByDate(notifications);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Notification", style: TextStyle(color: Colors.blue, fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var notification in notifications) {
                  notification.isRead = true;
                }
              });
            },
            child: Text("Mark all", style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: groupedNotifications.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...entry.value.map((item) => NotificationTile(
                item: item,
                onTap: () {
                  setState(() {
                    item.isRead = true;
                  });
                },
              )),
              SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}