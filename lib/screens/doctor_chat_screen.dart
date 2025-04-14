import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import '../models/message_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';

class DoctorChatScreen extends StatefulWidget {
  final Patient patient;

  const DoctorChatScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> messages = [];

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(Message(
        text: text,
        time: "Now",
        isSender: true,
      ));
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(patient.profileImage),
            ),
            const SizedBox(width: 10),
            Text(patient.name),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.video_call), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: messages[index]);
              },
            ),
          ),
          Text(
            "${patient.name.split(' ').first} is typing...",
            style: const TextStyle(color: Colors.blue),
          ),
          MessageInput(onSend: sendMessage),
        ],
      ),
    );
  }
}
