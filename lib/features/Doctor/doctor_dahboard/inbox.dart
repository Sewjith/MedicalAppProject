import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:go_router/go_router.dart';   
import 'package:intl/intl.dart';            
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart'; 
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/main_features/Chat/models/chat_service.dart'; 
import 'package:medical_app/features/doctor/doctor_dahboard/inbox_db.dart';
import 'package:medical_app/features/doctor/doctor_dahboard/message_detail.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> with SingleTickerProviderStateMixin { 
  final InboxDB _db = InboxDB();
  final TextEditingController _searchController = TextEditingController();

  Map<String, List<Map<String, dynamic>>> _groupedMessages = {};
  Map<String, List<Map<String, dynamic>>> _filteredMessages = {};
  Map<String, bool> _readStatus = {}; 
  bool _isLoadingMessages = true; 
  String? _messageError;

  
  late ChatService _chatService; // Use ChatService to fetch chats
  List<Map<String, dynamic>> _consultations = [];
  List<Map<String, dynamic>> _filteredConsultations = [];
  bool _isLoadingChats = true; // Loading state for chats
  String? _chatError;
  String? _doctorId;
  String? _doctorName;
  


  late TabController _tabController;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Initialize TabController

    // Fetch doctor details and then load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _initializeDoctorAndLoadData();
    });

    _searchController.addListener(_filterContent); // Listener to filter both
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose(); // Dispose TabController
    // Dispose ChatService if needed, though it might be stateless here
    super.dispose();
  }

  // Initialize Doctor Info and Load Both Data Types
  Future<void> _initializeDoctorAndLoadData() async {
     if (!mounted) return;
     debugPrint("[InboxPage] Initializing doctor info...");

     final userState = context.read<AppUserCubit>().state;
     if (userState is AppUserLoggedIn && userState.user.role == 'doctor') {
       _doctorId = userState.user.uid;
       _doctorName = '${userState.user.firstname ?? ''} ${userState.user.lastname ?? ''}'.trim();
       if (_doctorName!.isEmpty) _doctorName = "Doctor"; // Fallback name

       debugPrint("[InboxPage] Doctor Initialized - ID: $_doctorId, Name: $_doctorName");

       // Initialize ChatService *after* getting doctor info
       _chatService = ChatService(userName: _doctorName!, userRole: 'doctor');

       // Load both messages and chats
       await Future.wait([
         _loadMessages(),
         _loadConsultationChats(),
       ]);

     } else {
        if (mounted) {
          setState(() {
             _isLoadingMessages = false;
             _isLoadingChats = false;
             _messageError = "Doctor not logged in.";
             _chatError = "Doctor not logged in.";
          });
          debugPrint("[InboxPage] Initialization failed: Not logged in as doctor.");
        }
     }
  }


  Future<void> _loadMessages() async {
     if (!mounted) return;
     setState(() { _isLoadingMessages = true; _messageError = null; });
    try {
      final groupedMessages = await _db.getGroupedMessages();
      if (!mounted) return;
      setState(() {
        _groupedMessages = groupedMessages;
        _filteredMessages = Map.from(groupedMessages);
        _readStatus = Map.fromIterable( groupedMessages.keys, key: (key) => key, value: (_) => false, ); // Assuming initially unread
        _isLoadingMessages = false;
      });
      debugPrint("[InboxPage] Loaded ${_groupedMessages.length} regular message threads.");
    } catch (e) {
       if (!mounted) return;
      setState(() { _isLoadingMessages = false; _messageError = 'Error loading messages: ${e.toString()}'; });
      debugPrint("[InboxPage] Error loading messages: $e");
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(_messageError!), backgroundColor: Colors.red), );
    }
  }

  
  Future<void> _loadConsultationChats() async {
    if (_doctorId == null || !mounted) {
       debugPrint("[InboxPage] Cannot load chats, Doctor ID is null or widget not mounted.");
       if (mounted) setState(() { _isLoadingChats = false; _chatError = _chatError ?? "Doctor ID missing."; });
       return;
    }
    setState(() { _isLoadingChats = true; _chatError = null; });
    try {

      final consultations = await _chatService.getDoctorConsultations(_doctorId!);
      if (!mounted) return;
      setState(() {
        _consultations = consultations;
        _filteredConsultations = List.from(consultations); // Initialize filter
        _isLoadingChats = false;
      });
       debugPrint("[InboxPage] Loaded ${_consultations.length} consultation chats.");
    } catch (e) {
       if (!mounted) return;
      setState(() { _isLoadingChats = false; _chatError = 'Error loading chats: ${e.toString()}'; });
      debugPrint("[InboxPage] Error loading chats: $e");
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text(_chatError!), backgroundColor: Colors.red), );
    }
  }


  void _filterContent() { 
    final query = _searchController.text.toLowerCase();
    setState(() {
      // Filter Regular Messages
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

      // Filter Consultation Chats
      if (query.isEmpty) {
         _filteredConsultations = List.from(_consultations);
      } else {
         _filteredConsultations = _consultations.where((consult) {
             final patientName = (consult['patient_name'] ?? '').toLowerCase();
             // Optionally search last message content if available
             // final lastMessage = (consult['latest_message'] ?? '').toLowerCase();
             return patientName.contains(query); // || lastMessage.contains(query);
         }).toList();
      }

    });
  }

  // --- Helper to navigate to ChatScreen for Doctors ---
  void _navigateToChat(Map<String, dynamic> consultation) {
     final consultationId = consultation['consultation_id'] as String?;
     final patientName = consultation['patient_name'] as String?;
     final patientId = consultation['patient_id'] as String?; // Ensure patient_id is fetched

     if (_doctorId == null || _doctorName == null || consultationId == null || patientId == null || patientName == null) {
        debugPrint("[InboxPage] Error navigating to chat: Missing required data.");
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Cannot open chat. Missing information."), backgroundColor: Colors.red),
        );
        return;
     }

     debugPrint("[InboxPage] Navigating to chat. Consult ID: $consultationId, Doctor: $_doctorName ($_doctorId), Patient: $patientName ($patientId)");

     // Navigate using GoRouter
     context.go(
       '/chat/consultation',
       extra: {
         'consultationId': consultationId,
         'userName': _doctorName!,       // Doctor is the user here
         'userRole': 'doctor',          // Doctor's role
         'recipientName': patientName,   // Patient is the recipient
         'doctorName': _doctorName!,
         'patientName': patientName,
         'doctorId': _doctorId!,
         'patientId': patientId,
       },
     );
  }


  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time); // Use intl for formatting
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length == 1 || parts[0].isEmpty) return name.isNotEmpty ? name[0].toUpperCase() : '?';
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
        iconTheme: const IconThemeData(color: AppPallete.primaryColor),
        leading: context.canPop() ? IconButton( // Show back button if possible
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/d_dashboard'); // Fallback to doctor dashboard
            }
          },
        ) : null, // Otherwise no leading button (e.g., if root of a tab)

        bottom: TabBar(
           controller: _tabController,
           labelColor: AppPallete.primaryColor,
           unselectedLabelColor: Colors.grey,
           indicatorColor: AppPallete.primaryColor,
           tabs: const [
              Tab(text: 'Messages'),
              Tab(text: 'Chats'),
           ],
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0), // Adjust top padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search inbox...', // Updated hint
                hintStyle: const TextStyle(color: AppPallete.greyColor), // Use theme color
                prefixIcon: const Icon(Icons.search, color: AppPallete.greyColor), // Use theme color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppPallete.borderColor), // Use theme color
                ),
                 enabledBorder: OutlineInputBorder( // Consistent border
                   borderRadius: BorderRadius.circular(10),
                   borderSide: const BorderSide(color: AppPallete.borderColor),
                 ),
                 focusedBorder: OutlineInputBorder( // Highlight border on focus
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppPallete.primaryColor, width: 1.5),
                  ),
                filled: true,
                fillColor: AppPallete.whiteColor, // Use theme color
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Adjust padding
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMessageList(),
                  _buildChatList(),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  // Widget builder for regular messages
  Widget _buildMessageList() {
     if (_isLoadingMessages) return const Center(child: CircularProgressIndicator());
     if (_messageError != null) return Center(child: Text(_messageError!, style: TextStyle(color: Colors.red)));
     if (_filteredMessages.isEmpty) {
        return Center(
          child: Text(
            _searchController.text.isEmpty
                ? 'No regular messages found'
                : 'No results for "${_searchController.text}"',
            style: const TextStyle(color: AppPallete.textColor),
          ),
        );
     }

     return ListView.separated(
       itemCount: _filteredMessages.length,
       separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
       itemBuilder: (context, index) {
         final sender = _filteredMessages.keys.elementAt(index);
         final messages = _filteredMessages[sender]!;
         final latestMessage = messages.first;
         final isRead = _readStatus[sender] ?? false; // Use read status
         final messageCount = messages.length; // Example count

         DateTime parsedTime;
         try {
           parsedTime = DateTime.parse(latestMessage['created_at']);
         } catch (e) {
           parsedTime = DateTime.now(); // Fallback
         }

         return _buildMessageItem( // Use helper for consistency
           sender: sender,
           latestMessage: latestMessage['content'] ?? '',
           time: _formatTime(parsedTime),
           messageCount: isRead ? 0 : messageCount, // Show count only if unread
           isRead: isRead,
           onTap: () {
              // Mark as read and navigate to detail
             setState(() => _readStatus[sender] = true);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageDetailPage(
                    sender: sender,
                    messages: messages, // Pass all messages for this sender
                  ),
                ),
              ).then((_) {
              });
           },
         );
       },
     );
  }


  Widget _buildChatList() {
     if (_isLoadingChats) return const Center(child: CircularProgressIndicator());
     if (_chatError != null) return Center(child: Text(_chatError!, style: TextStyle(color: Colors.red)));
     if (_filteredConsultations.isEmpty) {
       return Center(
         child: Text(
           _searchController.text.isEmpty
               ? 'No active chats found'
               : 'No chat results for "${_searchController.text}"',
           style: const TextStyle(color: AppPallete.textColor),
         ),
       );
     }

     return ListView.separated(
       itemCount: _filteredConsultations.length,
       separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
       itemBuilder: (context, index) {
         final consultation = _filteredConsultations[index];
         final patientName = consultation['patient_name'] ?? 'Unknown Patient';
         final latestMessageContent = consultation['latest_message'] ?? 'No messages yet';

         DateTime lastTimestamp;
         try {
           lastTimestamp = DateTime.parse(consultation['last_timestamp'] ?? DateTime.now().toIso8601String());
         } catch (e) {
           lastTimestamp = DateTime.now();
         }


         final bool isChatRead = true; // Placeholder - needs unread logic
         final int chatMessageCount = 0; // Placeholder

         return _buildMessageItem( // Re-use the message item builder
           sender: patientName, // Show patient name as the "sender" in the list
           latestMessage: latestMessageContent,
           time: _formatTime(lastTimestamp),
           messageCount: chatMessageCount, // Use actual unread count later
           isRead: isChatRead, // Use actual read status later
           isChat: true, // Indicate this is a chat item
           onTap: () => _navigateToChat(consultation), // Navigate to ChatScreen
         );
       },
     );
  }


  // Modified _buildMessageItem to handle both messages and chats
  Widget _buildMessageItem({
    required String sender,
    required String latestMessage,
    required String time,
    required int messageCount, // Unread count
    required bool isRead,
    bool isChat = false, // Flag to differentiate
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12), // Reduced horizontal padding
        child: Row(
          children: [
            Container( // Avatar
              width: 45, // Slightly larger avatar
              height: 45,
              decoration: BoxDecoration(
                color: isChat ? Colors.green.shade100 : AppPallete.primaryColor.withOpacity(0.1), // Different color for chats
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isChat ? Icons.chat_bubble_outline : Icons.person_outline, // Different icon for chats
                  color: isChat ? Colors.green : AppPallete.primaryColor,
                  size: 24,
                ),
                // child: Text( // Alternative: Initials
                //   _getInitials(sender),
                //   style: TextStyle(
                //     color: isChat ? Colors.green : AppPallete.primaryColor,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded( // Message content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( // Sender Name
                    sender,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15, // Slightly smaller
                      color: isRead ? AppPallete.greyColor : AppPallete.textColor,
                    ),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text( // Latest Message Snippet
                    latestMessage,
                    style: TextStyle(color: isRead ? AppPallete.greyColor : AppPallete.textColor.withOpacity(0.9), fontSize: 14), // Slightly smaller
                    maxLines: 1, // Show only one line
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column( // Timestamp and Unread Badge
               crossAxisAlignment: CrossAxisAlignment.end,
               mainAxisAlignment: MainAxisAlignment.start,
               children: [
                   Text( // Timestamp
                     time,
                     style: const TextStyle(color: AppPallete.greyColor, fontSize: 12),
                   ),
                   if (messageCount > 0) ...[ // Unread Badge
                     const SizedBox(height: 5),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                       decoration: BoxDecoration(
                         color: Colors.redAccent, // Use a distinct color
                         borderRadius: BorderRadius.circular(10),
                       ),
                       child: Text(
                         '$messageCount',
                         style: const TextStyle( color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, ),
                       ),
                     ),
                   ] else ...[
                      const SizedBox(height: 21), // Maintain height even if no badge
                   ]
               ],
            ),
          ],
        ),
      ),
    );
  }
}
