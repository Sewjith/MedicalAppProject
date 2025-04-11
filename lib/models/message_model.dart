


class Message {
  final String text;
  final String time;
  final bool isSender;
  final bool isVoiceNote;
  final String? voiceNoteUrl;

  Message({
    required this.text,
    required this.time,
    required this.isSender,
    this.isVoiceNote = false,
    this.voiceNoteUrl,
  });
}

List<Message> messages = [
  Message(text: "Hello, doctor!", time: "09:00", isSender: true),
  Message(text: "How can I help you?", time: "09:30", isSender: false),
  Message(text: "I have a headache.", time: "09:43", isSender: true),
  Message(text: "Here’s a voice note for you.", time: "09:50", isSender: false, isVoiceNote: true, voiceNoteUrl: "audio.mp3"),
  Message(text: "Got it. Thanks!", time: "09:55", isSender: true),
];