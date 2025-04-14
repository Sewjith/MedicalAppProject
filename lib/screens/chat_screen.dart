import 'package:flutter/material.dart';
import '../models/doctor_model.dart';
import '../models/message_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';
import 'DoctorInfoScreen.dart';



class ChatScreen extends StatefulWidget {
  final Doctor doctor;

  ChatScreen({required this.doctor});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      messages.add(Message(text: text, time: "Now", isSender: true));
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorInfoScreen(doctor: widget.doctor),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(widget.doctor.profileImage),
              ),
              SizedBox(width: 10),
              Text(widget.doctor.name),
            ],
          ),
        ),
        actions: [
          IconButton(icon: Icon(Icons.call), onPressed: () {}),
          IconButton(icon: Icon(Icons.video_call), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: messages[index]);
              },
            ),
          ),
          Text("Dr. ${widget.doctor.name.split(" ").last} is typing...", style: TextStyle(color: Colors.blue)),
          MessageInput(onSend: sendMessage),
        ],
      ),
    );
  }
}
