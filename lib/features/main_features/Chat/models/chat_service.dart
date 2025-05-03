// @@@@@-FILE MODIFICATION START-@@@@@
// File: lib/features/main_features/Chat/models/chat_service.dart
// Reason: Remove RPC call and implement client-side grouping for getDoctorConsultations because the RPC function doesn't exist in the database.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ChatService {
  final String userName;
  final String userRole;
  final _supabase = Supabase.instance.client;

  String? _consultationId;
  String? _doctorId;
  String? _patientId;
  String? _doctorName;
  String? _patientName;

  RealtimeChannel? _channel;

  Function(String senderName, String message, String senderRole)? onMessageReceived;

  ChatService({
    required this.userName,
    required this.userRole,
  });

  Future<void> initialize() async {
    debugPrint('[ChatService] Initialized for user: $userName, role: $userRole');
    _validateRole(userRole);
  }

  String _mapRoleForDatabase(String appRole) {
    final lowerCaseRole = appRole.toLowerCase();
    if (lowerCaseRole == 'patient') {
      return 'Patient';
    } else if (lowerCaseRole == 'doctor') {
      return 'Doctor';
    } else {
      debugPrint("[ChatService] ERROR: Unexpected user role '$appRole' received.");
      throw ArgumentError("Invalid user role provided to ChatService: $appRole");
    }
  }

  void _validateRole(String appRole) {
     try {
        _mapRoleForDatabase(appRole);
     } catch (e) {
        debugPrint("[ChatService] Initialization Error: $e");
     }
  }

  Future<List<Map<String, dynamic>>> getDoctorsWithPastAppointments(String patientId) async {
    debugPrint('[ChatService] Fetching doctors with past appointments for patient ID: $patientId');
    if (patientId.isEmpty) {
      debugPrint('[ChatService] Error: Patient ID is empty.');
      throw Exception('Patient ID cannot be empty.');
    }
    try {

      final appointmentResponse = await _supabase
          .from('appointments')
          .select('doctor_id')
          .eq('patient_id', patientId)
          .not('doctor_id', 'is', null);


      if (appointmentResponse.isEmpty) {
        debugPrint('[ChatService] No past appointments found for patient $patientId.');
        return [];
      }

      final doctorIds = appointmentResponse
          .map((appt) => appt['doctor_id'] as String?)
          .where((id) => id != null && id.isNotEmpty)
          .toSet()
          .toList();

      if (doctorIds.isEmpty) {
         debugPrint('[ChatService] No valid doctor IDs found in appointments.');
         return [];
      }

      debugPrint('[ChatService] Found ${doctorIds.length} unique doctor IDs: $doctorIds');


      final doctorsResponse = await _supabase
          .from('doctors')
          .select('id, title, first_name, last_name, specialty')
          .inFilter('id', doctorIds)
          .order('last_name', ascending: true);

      debugPrint('[ChatService] Fetched details for ${doctorsResponse.length} doctors.');
      return List<Map<String, dynamic>>.from(doctorsResponse);

    } on PostgrestException catch (e) {
       debugPrint('[ChatService] Supabase Error fetching doctors: ${e.message}, Code: ${e.code}, Details: ${e.details}');
       throw Exception('Database error fetching doctors: ${e.message}');
    }
    catch (e) {
      debugPrint('[ChatService] Unexpected Error fetching doctors with past appointments: $e');
      throw Exception('Failed to fetch doctors: $e');
    }
  }

  String _generateConsultationId(String patientId, String doctorId) {
    final ids = [patientId, doctorId]..sort();
    final consultationId = 'consult_${ids[0]}_${ids[1]}';
    debugPrint('[ChatService] Generated Consultation ID: $consultationId');
    return consultationId;
  }

  Future<void> joinConsultation({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String patientName,
  }) async {
    _consultationId = _generateConsultationId(patientId, doctorId);
    _doctorId = doctorId;
    _patientId = patientId;
    _doctorName = doctorName;
    _patientName = patientName;

    debugPrint('[ChatService] Joining Consultation ID: $_consultationId');
    debugPrint('[ChatService] Participants: Doctor $doctorName ($doctorId), Patient $patientName ($patientId)');

    try {
      await _ensureConsultationRecordExists();
      _subscribeToMessages();
    } catch (e) {
      debugPrint('[ChatService] Error during joinConsultation setup: $e');
      rethrow;
    }
  }

  Future<void> _ensureConsultationRecordExists() async {
     if (_consultationId == null) return;
     try {

        final response = await _supabase
            .from('consultation_messages')
            .select('id')
            .eq('consultation_id', _consultationId!)
            .limit(1)
            .count(CountOption.exact);


        if (response.count == 0) {
           debugPrint('[ChatService] Creating initial system message for $_consultationId.');

           await _supabase.from('consultation_messages').insert({
             'consultation_id': _consultationId!,
             'sender_name': 'System',
             'sender_role': 'System',
             'content': 'Consultation started',
             'doctor_name': _doctorName ?? 'N/A',
             'patient_name': _patientName ?? 'N/A',
             'doctor_id': _doctorId,
             'patient_id': _patientId,
           });
        } else {
            debugPrint('[ChatService] Consultation record already exists for $_consultationId.');
        }
     } catch (e) {
         debugPrint('[ChatService] Error ensuring consultation record exists: $e');
          if (e is PostgrestException && e.message.contains("schema cache")) {
            debugPrint("[ChatService] Hint: Schema cache error likely means the table/column structure is not as expected in Supabase.");
         }

     }
  }


  void _subscribeToMessages() {
    if (_consultationId == null) return;
    _unsubscribeFromMessages();

    final channelName = 'consultation:$_consultationId';
    debugPrint('[ChatService] Subscribing to channel: $channelName');
    _channel = _supabase.channel(channelName);

    _channel!
      .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'consultation_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'consultation_id',
            value: _consultationId!,
          ),
          callback: (payload) {
            debugPrint('[ChatService] Realtime Payload Received: ${payload.eventType}, Record: ${payload.newRecord}');
            if (payload.newRecord != null) {
              final message = payload.newRecord!;
              final content = message['content'] as String?;
              final senderName = message['sender_name'] as String?;
              final senderRole = message['sender_role'] as String?;

              if (content != null && senderName != null && senderRole != null &&
                  senderName != userName &&
                  senderRole != 'System') {
                if (onMessageReceived != null) {
                  debugPrint("[ChatService] Firing onMessageReceived for: $senderName ($senderRole) - $content");
                  onMessageReceived!(senderName, content, senderRole);
                } else {
                  debugPrint("[ChatService] onMessageReceived callback is null.");
                }
              } else {
                debugPrint("[ChatService] Filtered out system/own message: $content by $senderName");
              }
            } else {
              debugPrint("[ChatService] Realtime payload had no newRecord: ${payload.eventType}");
            }
          })
      .subscribe(
          (status, [error]) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              debugPrint('[ChatService] Successfully subscribed to $channelName');
            } else {
              debugPrint('[ChatService] Subscription failed for $channelName: Status $status, Error: $error');
            }
          },
       );
  }


  void _unsubscribeFromMessages() {
    if (_channel != null) {
      debugPrint('[ChatService] Unsubscribing from channel...');
      try {
        _supabase.removeChannel(_channel!);
      } catch (e) {
         debugPrint('[ChatService] Error removing channel: $e');
      }
      _channel = null;
    }
  }


  Future<void> sendMessage(String message) async {
    if (_consultationId == null || _doctorId == null || _patientId == null) {
        debugPrint("[ChatService] sendMessage Error: Cannot send message, service not fully initialized (consultId=$_consultationId, doctorId=$_doctorId, patientId=$_patientId)");
        throw Exception("Cannot send message: Chat session not properly initialized.");
    }
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      return;
    }

    String dbFormattedRole;
    try {

        dbFormattedRole = _mapRoleForDatabase(userRole);
    } catch (e) {
       debugPrint("[ChatService] sendMessage Error: $e");
       throw Exception("Cannot send message due to invalid user role.");
    }


    debugPrint('[ChatService] Preparing to send message. Role: $userRole -> DB Role: $dbFormattedRole');

    try {
      debugPrint('[ChatService] Sending Message: "$trimmedMessage" from $userName ($dbFormattedRole) in consult $_consultationId');

      await _supabase.from('consultation_messages').insert({
        'consultation_id': _consultationId!,
        'sender_name': userName,
        'sender_role': dbFormattedRole,
        'content': trimmedMessage,
        'doctor_name': _doctorName ?? 'N/A',
        'patient_name': _patientName ?? 'N/A',
        'doctor_id': _doctorId,
        'patient_id': _patientId,
      });
      debugPrint('[ChatService] Message sent successfully.');
    } on PostgrestException catch (e){
       debugPrint('[ChatService] Supabase Error sending message: ${e.message}');
       if (e.message.contains("consultation_messages_sender_role_check")) {
           debugPrint("[ChatService] CHECK CONSTRAINT VIOLATION: The value '$dbFormattedRole' for sender_role is NOT ALLOWED by the database. Check the constraint definition in Supabase!");
           throw Exception('Database constraint violated for sender role.');
       } else if (e.message.contains("foreign key constraint")) {
            debugPrint("[ChatService] FOREIGN KEY VIOLATION: Ensure doctor_id ('$_doctorId') and patient_id ('$_patientId') exist in their respective tables.");
            throw Exception('Database error: Invalid doctor or patient reference.');
       }
       throw Exception('Failed to send message: ${e.message}');
    }
    catch (e) {
      debugPrint('[ChatService] Unexpected Error sending message: $e');
      throw Exception('Failed to send message.');
    }
  }


  // --- MODIFIED METHOD FOR DOCTOR - USING CLIENT-SIDE GROUPING ---
  Future<List<Map<String, dynamic>>> getDoctorConsultations(String doctorId) async {
      debugPrint('[ChatService] Fetching consultations for Doctor ID: $doctorId (Client-side grouping)');
      if (doctorId.isEmpty) {
          debugPrint('[ChatService] Error: Doctor ID is empty.');
          throw Exception('Doctor ID cannot be empty.');
      }
      try {
          // Fetch all messages involving the doctor, ordered to get latest first per group
          final response = await _supabase
              .from('consultation_messages')
              // Select necessary fields for display and identification
              .select('consultation_id, patient_name, patient_id, content, timestamp, doctor_id')
              .eq('doctor_id', doctorId) // Filter by doctor_id
              .order('timestamp', ascending: false); // Order by time DESC

          if (response == null || response is! List || response.isEmpty) {
             debugPrint('[ChatService] No messages found for Doctor ID: $doctorId');
             return [];
          }

          final allMessages = List<Map<String, dynamic>>.from(response);
          final Map<String, Map<String, dynamic>> latestConsultations = {};

          for (var message in allMessages) {
              final consultId = message['consultation_id'] as String?;
              if (consultId == null) continue;

              // Since messages are ordered descending, the first time we see a consultId, it's the latest message
              if (!latestConsultations.containsKey(consultId)) {
                  latestConsultations[consultId] = {
                      'consultation_id': consultId,
                      'patient_name': message['patient_name'] ?? 'Unknown Patient',
                      'patient_id': message['patient_id'] ?? '', // Important for joining chat later
                      'latest_message': message['content'] ?? '',
                      // Use timestamp from the message itself
                      'last_timestamp': message['timestamp'] ?? DateTime.now().toIso8601String(),
                      // Store doctor_id as well if needed when joining
                      'doctor_id': message['doctor_id'] ?? doctorId,
                  };
              }
          }

          final resultList = latestConsultations.values.toList();
          // Optional: Sort the final list again by timestamp if needed (though it should be implicitly sorted by latest message time)
          resultList.sort((a, b) => DateTime.parse(b['last_timestamp']).compareTo(DateTime.parse(a['last_timestamp'])));

          debugPrint('[ChatService] Found ${resultList.length} unique consultations for Doctor ID: $doctorId via client-side grouping.');
          return resultList;


      } on PostgrestException catch (e) {
          debugPrint('[ChatService] Supabase Error fetching doctor consultations: ${e.message}');
          throw Exception('Database error fetching consultations: ${e.message}');
      } catch (e) {
          debugPrint('[ChatService] Unexpected Error fetching doctor consultations: $e');
          throw Exception('Failed to fetch consultations: $e');
      }
  }
  // --- END MODIFIED METHOD ---


  void dispose() {
    debugPrint('[ChatService] Disposing ChatService for $userName...');
    _unsubscribeFromMessages();
    _consultationId = null;
    _doctorId = null;
    _patientId = null;
    _doctorName = null;
    _patientName = null;
    onMessageReceived = null;
    debugPrint('[ChatService] Disposed.');
  }
}
// @@@@@-FILE MODIFICATION END-@@@@@