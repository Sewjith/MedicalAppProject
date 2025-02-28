import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inbox UI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppPallete.primaryColor),
        useMaterial3: true,
        scaffoldBackgroundColor: AppPallete.whiteColor,
      ),
      home: const InboxPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  List<Message> allMessages = [
    Message(name: 'Sarah M.', message: 'Kelly: Let me see your last month...', time: '1:34 PM', unreadCount: 2, image: 'assets/images/in1.webp'),
    Message(name: 'Martinez', message: 'Kelly: Let me see your last month...', time: '1:34 PM', unreadCount: 0, image: 'assets/images/in2.webp'),
    Message(name: 'Justine', message: 'Kelly: Let me see your last month...', time: '1:34 PM', unreadCount: 2, image: 'assets/images/in3.jpg'),
    Message(name: 'Christian', message: 'Kelly: Let me see your last month...', time: '1:34 PM', unreadCount: 1, image: 'assets/images/in4.jpg'),
  ];

  List<Message> filteredMessages = [];
  TextEditingController searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    filteredMessages = allMessages;
    searchController.addListener(_filterMessages);
  }

  void _filterMessages() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredMessages = allMessages.where((message) {
        return message.name.toLowerCase().contains(query) ||
            message.message.toLowerCase().contains(query);
      }).toList();
    });
  }

  void markAsRead(int index) {
    setState(() {
      filteredMessages[index] = filteredMessages[index].copyWith(unreadCount: 0);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inbox',
          style: TextStyle(
            color: AppPallete.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppPallete.whiteColor,
        iconTheme: const IconThemeData(color: AppPallete.primaryColor),
      ),
      body: Container(
        color: AppPallete.whiteColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppPallete.darkText),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredMessages.length,
                itemBuilder: (context, index) {
                  return InboxItem(
                    messageData: filteredMessages[index],
                    onTap: () {
                      markAsRead(index);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessageDetailsPage(message: filteredMessages[index]),
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
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class InboxItem extends StatelessWidget {
  final Message messageData;
  final VoidCallback onTap;

  const InboxItem({
    required this.messageData,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage: AssetImage(messageData.image),
      ),
      title: Text(
        messageData.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: messageData.unreadCount > 0 ? AppPallete.textColor : AppPallete.greyColor,
        ),
      ),
      subtitle: Text(
        messageData.message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(messageData.time, style: const TextStyle(fontSize: 12, color: AppPallete.greyColor)),
          if (messageData.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppPallete.errorColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${messageData.unreadCount}',
                style: const TextStyle(color: AppPallete.whiteColor, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class MessageDetailsPage extends StatelessWidget {
  final Message message;

  const MessageDetailsPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          message.name,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          message.message,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class Message {
  final String name;
  final String message;
  final String time;
  final int unreadCount;
  final String image;

  Message({
    required this.name,
    required this.message,
    required this.time,
    required this.unreadCount,
    required this.image,
  });

  Message copyWith({String? name, String? message, String? time, int? unreadCount, String? image}) {
    return Message(
      name: name ?? this.name,
      message: message ?? this.message,
      time: time ?? this.time,
      unreadCount: unreadCount ?? this.unreadCount,
      image: image ?? this.image,
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({required this.selectedIndex, required this.onItemTapped, super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: AppPallete.primaryColor,
      unselectedItemColor: AppPallete.greyColor,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "",
        ),
      ],
    );
  }
}
