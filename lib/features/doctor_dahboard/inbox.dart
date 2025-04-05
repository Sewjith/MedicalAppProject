import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor_dahboard/inbox_db.dart';
import 'package:medical_app/features/doctor_dahboard/message_detail.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final InboxDB _db = InboxDB();
  final TextEditingController _searchController = TextEditingController();

  Map<String, List<Map<String, dynamic>>> _groupedMessages = {};
  Map<String, List<Map<String, dynamic>>> _filteredMessages = {};
  Map<String, bool> _readStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _searchController.addListener(_filterMessages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final groupedMessages = await _db.getGroupedMessages();
      setState(() {
        _groupedMessages = groupedMessages;
        _filteredMessages = Map.from(groupedMessages);
        _readStatus = Map.fromIterable(
          groupedMessages.keys,
          key: (key) => key,
          value: (_) => false,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages: ${e.toString()}')),
      );
    }
  }


  void _filterMessages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMessages = Map.from(_groupedMessages);
      } else {
        _filteredMessages = {};
        _groupedMessages.forEach((sender, messages) {
          if (sender.toLowerCase().contains(query) ||
              messages.any((msg) => (msg['content'] ?? '').toString().toLowerCase().contains(query))) {
            _filteredMessages[sender] = messages;
          }
        });
      }
    });
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.secondaryColor,
      appBar: AppBar(
        title: const Text(
          'Inbox',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppPallete.primaryColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppPallete.secondaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppPallete.primaryColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or message...',
                hintStyle: TextStyle(color: AppPallete.textColor),
                prefixIcon: Icon(Icons.search, color: AppPallete.textColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppPallete.darkText),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _filteredMessages.isEmpty
                  ? Center(
                child: Text(
                  _searchController.text.isEmpty
                      ? 'No messages found'
                      : 'No results for "${_searchController.text}"',
                  style: TextStyle(color: AppPallete.textColor),
                ),
              )
                  : ListView.separated(
                itemCount: _filteredMessages.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  final sender = _filteredMessages.keys.elementAt(index);
                  final messages = _filteredMessages[sender]!;
                  final latestMessage = messages.first;
                  final isRead = _readStatus[sender] ?? false;
                  final messageCount = messages.length;

                  return _buildMessageItem(
                    sender: sender,
                    latestMessage: latestMessage['content'] ?? '',
                    time: _formatTime(DateTime.parse(latestMessage['created_at'])),
                    messageCount: messageCount,
                    isRead: isRead,
                    onTap: () {
                      setState(() => _readStatus[sender] = true);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessageDetailPage(
                            sender: sender,
                            messages: messages,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem({
    required String sender,
    required String latestMessage,
    required String time,
    required int messageCount,
    required bool isRead,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppPallete.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getInitials(sender),
                  style: TextStyle(
                    color: AppPallete.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sender,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isRead ? AppPallete.greyColor : AppPallete.textColor,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            time,
                            style: TextStyle(color: AppPallete.greyColor, fontSize: 12),
                          ),
                          if (!isRead && messageCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$messageCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    latestMessage,
                    style: TextStyle(color: AppPallete.textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}