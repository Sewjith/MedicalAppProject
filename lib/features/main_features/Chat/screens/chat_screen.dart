import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/bottom_nav_bar.dart'; // Added Bottom Nav Bar
import 'package:medical_app/features/Patient/patient_dashboard/menu_nav.dart'; // Added Side Menu (adjust path if needed)
import 'package:medical_app/features/main_features/Chat/models/chat_message.dart';
import 'package:medical_app/features/main_features/Chat/models/chat_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String consultationId;
  final String userName;
  final String userRole;
  final String recipientName;
  final String doctorName;
  final String patientName;
  final String doctorId; // Added doctorId
  final String patientId; // Added patientId

  const ChatScreen({
    Key? key,
    required this.consultationId,
    required this.userName,
    required this.userRole,
    required this.recipientName,
    required this.doctorName,
    required this.patientName,
    required this.doctorId, // Require doctorId
    required this.patientId, // Require patientId
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  late ChatService _chatService;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Key for drawer

  @override
  void initState() {
    super.initState();
    _setupChatService();
    _loadMessages();
  }

  void _setupChatService() {
    _chatService = ChatService(
      userName: widget.userName,
      userRole: widget.userRole,
    );

    _chatService.onMessageReceived = (senderName, message, senderRole) {
      if (!mounted) return; // Check if widget is still in the tree
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(), 
          consultationId: widget.consultationId,
          senderName: senderName,
          senderRole: senderRole,
          content: message,
          timestamp: DateTime.now(),
          doctorName: widget.doctorName,
          patientName: widget.patientName,

        ));
      });
      _scrollToBottom();
    };

    _chatService.initialize().then((_) {
      
      _chatService.joinConsultation(
        patientId: widget.patientId,   
        doctorId: widget.doctorId,      
        doctorName: widget.doctorName,  
        patientName: widget.patientName, 
      );
     
    });
  }

  Future<void> _loadMessages() async {
    try {
      final response = await _supabase
          .from('consultation_messages')
          .select()
          .eq('consultation_id', widget.consultationId)
          .order('timestamp', ascending: true);

      if (!mounted) return; // Check before updating state

      setState(() {
        _messages.clear();
        for (var item in response) {
          final message = ChatMessage.fromMap(item);
          // Filter out system/join/leave messages
          if (message.content != '_joined_' &&
              message.content != '_left_' &&
              message.content != 'Consultation created' &&
              message.content != 'Consultation started') {
            _messages.add(message);
          }
        }
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint('Error loading messages: $e');
       if (!mounted) return;
      setState(() {
        _isLoading = false;
        // Optionally show an error message to the user
      });
    }
  }

void _sendMessage() async {
  final text = _messageController.text.trim();
  if (text.isEmpty) return;

  final newMessage = ChatMessage(
    id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
    consultationId: widget.consultationId,
    senderName: widget.userName,
    senderRole: widget.userRole,
    content: text,
    timestamp: DateTime.now(),
    doctorName: widget.doctorName,
    patientName: widget.patientName,
    // Pass IDs if needed
    // doctorId: widget.doctorId,
    // patientId: widget.patientId,
  );

  if (!mounted) return;
  setState(() {
    _messages.add(newMessage); // Add optimistic UI update
  });

  _messageController.clear();
  _scrollToBottom(); // Scroll after adding message locally

  try {
    // Pass IDs to chat service's send method if required
    await _chatService.sendMessage(
      text,
      // doctorId: widget.doctorId, // Pass if needed
      // patientId: widget.patientId, // Pass if needed
    );
    // Message sending handled by service, UI already updated
  } catch (e) {
    // Handle potential send error (e.g., show snackbar, revert UI update)
    debugPrint("Error sending message via service: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send message: $e"), backgroundColor: Colors.red),
      );
      // Optional: Remove the message from UI if send failed
      // setState(() {
      //   _messages.remove(newMessage);
      // });
    }
  }
}

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Use WidgetsBinding to schedule scroll after layout
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) { // Check again inside callback
           _scrollController.animateTo(
             _scrollController.position.maxScrollExtent,
             duration: const Duration(milliseconds: 300),
             curve: Curves.easeOut,
           );
        }
      });
    }
  }

   // --- Function to handle Bottom Nav Bar tap ---
   void _onBottomNavItemTapped(int index) {
     // Implement navigation logic based on index
     // Example using GoRouter (adjust routes as needed):
     switch (index) {
       case 0: // Home
         // Determine dashboard based on role
         if (widget.userRole == 'patient') {
           context.go('/p_dashboard');
         } else if (widget.userRole == 'doctor') {
           context.go('/d_dashboard');
         } else {
           context.go('/home'); // Fallback
         }
         break;
       case 1: // Chat - Already here, maybe navigate to chat list?
         context.go('/chat/login'); // Go back to chat setup for now
         break;
       case 2: // Profile
          if (widget.userRole == 'patient') {
           context.go('/patient/profile');
         } else if (widget.userRole == 'doctor') {
           context.go('/doctor/profile');
         }
         break;
       case 3: // Calendar (Appointments/Schedule)
         if (widget.userRole == 'patient') {
           context.go('/patient/appointment/history');
         } else if (widget.userRole == 'doctor') {
           context.go('/doctor/appointment/schedule');
         }
         break;
       // Add cases for other indices if your BottomNavBar has more items
     }
   }
   // --- End Bottom Nav Bar tap handler ---

  @override
  Widget build(BuildContext context) {
    // Determine recipient role for display purposes (optional)
    // final recipientRole = widget.userRole == 'Doctor' ? 'Patient' : 'Doctor';

    return Scaffold(
      key: _scaffoldKey, // Assign key to Scaffold
      appBar: AppBar(
        leading: IconButton( // Add drawer button
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(), // Open drawer
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat with ${widget.recipientName}'),
            Text(
              'Consultation ID: ${widget.consultationId}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
              ),
            ),
          ],
        ),
         // You might want to add other actions like video call button here
        // actions: [
        //   IconButton(icon: Icon(Icons.video_call), onPressed: () { /* Video call logic */ })
        // ],
      ),
      // --- Add Drawer ---
      drawer: Drawer(
         child: SideMenu(), // Use your side menu widget
       ),
      // --- End Add Drawer ---
      body: Column(
        children: [
          _buildConsultationInfo(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text('No messages yet. Start the conversation!'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(10),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderName == widget.userName;
                          final isDoctor = message.senderRole == 'Doctor';

                          return _buildMessageBubble(message, isMe, isDoctor);
                        },
                      ),
          ),
          const Divider(height: 1),
          _buildMessageInput(),
        ],
      ),
      // --- Add Bottom Navigation Bar ---
       bottomNavigationBar: BottomNavBar(
         selectedIndex: 1, // Set current index (e.g., 1 for Chat)
         onItemTapped: _onBottomNavItemTapped, // Handle taps
       ),
       // --- End Add Bottom Navigation Bar ---
    );
  }

  // --- Other build methods remain largely the same ---

   Widget _buildConsultationInfo() {
     return Container(
       color: Colors.blue.withOpacity(0.1),
       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text('Doctor:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
               Text(widget.doctorName), // Display doctor name
               Text("ID: ${widget.doctorId}", style: TextStyle(fontSize: 10, color: Colors.grey)), // Display Doctor ID
             ],
           ),
           Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               const Text('Patient:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
               Text(widget.patientName), // Display patient name
               Text("ID: ${widget.patientId}", style: TextStyle(fontSize: 10, color: Colors.grey)), // Display Patient ID
             ],
           ),
         ],
       ),
     );
   }

   Widget _buildMessageBubble(ChatMessage message, bool isMe, bool isDoctor) {
     final bubbleColor = isMe
         ? Colors.blue.shade100
         : isDoctor
             ? Colors.green.shade50
             : Colors.grey.shade200;
     final bubbleAlignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
     final textColor = isMe ? Colors.black87 : Colors.black;

     return Align(
       alignment: bubbleAlignment,
       child: Container(
         constraints: BoxConstraints(
           maxWidth: MediaQuery.of(context).size.width * 0.75,
         ),
         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
         padding: const EdgeInsets.all(12),
         decoration: BoxDecoration(
           color: bubbleColor,
           borderRadius: BorderRadius.circular(12),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.05),
               blurRadius: 2,
               offset: const Offset(0, 1),
             ),
           ],
         ),
         child: Column(
           crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, // Align timestamp
           children: [
             if (!isMe) // Show sender info only for other user
               Padding(
                 padding: const EdgeInsets.only(bottom: 4),
                 child: Text(
                   '${message.senderName} (${message.senderRole})',
                   style: TextStyle(
                     fontWeight: FontWeight.bold,
                     fontSize: 12,
                     color: isDoctor ? Colors.green.shade800 : Colors.blue.shade800,
                   ),
                 ),
               ),
             Text(
               message.content,
               style: TextStyle(fontSize: 16, color: textColor),
             ),
             Padding(
               padding: const EdgeInsets.only(top: 4),
               child: Text(
                 _formatTime(message.timestamp),
                 style: TextStyle(
                   fontSize: 10,
                   color: Colors.grey.shade600,
                 ),
                 // textAlign: isMe ? TextAlign.right : TextAlign.left, // Align timestamp based on sender
               ),
             ),
           ],
         ),
       ),
     );
   }

   Widget _buildMessageInput() {
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       color: Colors.white, // Or Theme.of(context).cardColor
       child: Row(
         children: [
           Expanded(
             child: TextField(
               controller: _messageController,
               decoration: InputDecoration(
                 hintText: 'Type a message',
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(24),
                   borderSide: BorderSide.none,
                 ),
                 filled: true,
                 fillColor: Colors.grey.shade100,
                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Adjusted padding
               ),
               textInputAction: TextInputAction.send,
               onSubmitted: (_) => _sendMessage(),
               maxLines: null, // Allow multi-line input
             ),
           ),
           IconButton(
             icon: const Icon(Icons.send, color: Colors.blue),
             onPressed: _sendMessage,
           ),
         ],
       ),
     );
   }

   String _formatTime(DateTime dateTime) {
     final now = DateTime.now();
     final today = DateTime(now.year, now.month, now.day);
     final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

     if (messageDate == today) {
       return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'; // HH:MM format for today
     } else {
       // Format for previous days (optional: add more detail like year)
       return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
     }
   }

   @override
   void dispose() {
     _messageController.dispose();
     _scrollController.dispose();
     _chatService.dispose(); // Important: Dispose chat service
     super.dispose();
   }
}