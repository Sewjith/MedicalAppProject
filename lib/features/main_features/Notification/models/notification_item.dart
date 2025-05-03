import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final String dateGroup;
  final IconData icon;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.dateGroup,
    required this.icon,
    this.isRead = false,
  });
}
