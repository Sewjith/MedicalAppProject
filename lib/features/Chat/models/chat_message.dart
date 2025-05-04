class ChatMessage {
  final String id;
  final String consultationId;
  final String senderName;
  final String senderRole; // 'Doctor' or 'Patient'
  final String content;
  final DateTime timestamp;
  final String? doctorName;
  final String? patientName;

  ChatMessage({
    required this.id,
    required this.consultationId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.timestamp,
    this.doctorName,
    this.patientName,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      consultationId: map['consultation_id'] ?? '',
      senderName: map['sender_name'] ?? '',
      senderRole: map['sender_role'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
      doctorName: map['doctor_name'],
      patientName: map['patient_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'consultation_id': consultationId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'doctor_name': doctorName,
      'patient_name': patientName,
    };
  }
}