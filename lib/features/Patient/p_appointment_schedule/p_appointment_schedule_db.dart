import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart'; // Ensure Uuid is imported
import 'package:intl/intl.dart'; // Import intl for date/time formatting

class DatabaseService {
  final supabase = Supabase.instance.client;
  final _uuid = const Uuid(); // UUID generator instance


  Future<bool> bookAppointment({
    required String patientId,
    required String doctorId,
    required String problemDesc,
    required DateTime date,
    required String time, // Expects formatted time string like "9:30 AM"
    required String patientName,
    required int patientAge,
    required String patientGender,

    required String doctorName,
  }) async {
    String? bookedAppointmentId; // To store the ID of the booked appointment

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      DateTime parsedSelectedTime;
      try {
        parsedSelectedTime = DateFormat('h:mm a').parseStrict(time);
      } catch (e) {
        debugPrint(
            "[BookAppointment] FATAL Error parsing time string '$time': $e");
        throw Exception(
            "Invalid time format selected ($time). Cannot proceed.");
      }
      final DateTime appointmentDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        parsedSelectedTime.hour,
        parsedSelectedTime.minute,
      );
      final String formattedTimestamp = appointmentDateTime.toIso8601String();
      String storageTime = DateFormat('HH:mm:ss').format(parsedSelectedTime);

      final appointmentUuid = _uuid.v4(); // Generate UUID for appointment
      bookedAppointmentId = appointmentUuid; // Store it

      final Map<String, dynamic> insertData = {
        'appointment_id': appointmentUuid, // Use the generated UUID
        'patient_id': patientId,
        'doctor_id': doctorId,
        'appointment_datetime': formattedTimestamp,
        'appointment_date': formattedDate,
        'appointment_time': storageTime,
        'notes': problemDesc.isEmpty ? "No description provided" : problemDesc,
        'appointment_status': 'upcoming',
        'created_at': DateTime.now().toIso8601String(),
        'patient_name': patientName,
        'patient_age': patientAge,
        'patient_gender': patientGender,
        'Payment Status': 'pending', // Default payment status
      };

      debugPrint(
          "[BookAppointment] Attempting to insert appointment data: $insertData");
      await supabase.from('appointments').insert(insertData);
      debugPrint(
          "[BookAppointment] Appointment booked successfully with ID: $bookedAppointmentId.");

      // --- Add Notification Record ---
      try {
        // Generate UUID for the notification ID
        final notificationUuid = _uuid.v4();

        // Format the date part of the message for clarity (e.g., "May 04")
        final formattedAppointmentDate = DateFormat('MMM dd').format(date);
        final notificationMessage =
            "Reminder: Your appointment with $doctorName is scheduled for $formattedAppointmentDate at $time.";

        final notificationData = {
          // Add the generated notification_id
          'notification_id': notificationUuid,
          'receiver_id': patientId,
          'doctor_id': doctorId,
          'receiver_type': 'patient', // Target the patient
          'message': notificationMessage,
          'type':
              'appointment_reminder', // Specific type for appointment reminders
          'reference_id': bookedAppointmentId, // Link to the appointment record
          'reference_type': 'appointment',
          'read_status': false, // Default read status to false
          'created_at':
              DateTime.now().toIso8601String(), // Ensure created_at is set
        };
        debugPrint(
            "[BookAppointment] Attempting to insert notification data: $notificationData");
        await supabase.from('notifications').insert(notificationData);
        debugPrint(
            "[BookAppointment] Notification record created successfully with ID: $notificationUuid.");
      } catch (notificationError) {

        debugPrint(
            "[BookAppointment] WARNING: Failed to create notification record: $notificationError");

      }


      return true; // Appointment booked (notification attempt logged)
    } catch (error) {
      if (error is PostgrestException) {
        debugPrint(
            "[BookAppointment] PostgrestException: code=${error.code}, message=${error.message}, details=${error.details}, hint=${error.hint}");

  
        String detailsString = '';
        if (error.details is String) {
          detailsString = error.details as String;
        } else if (error.details != null) {

          detailsString = error.details.toString();
        }


        if (error.code == '23505') {
          // unique constraint violation
          if (detailsString.contains('appointments_pkey') ||
              detailsString.contains(
                  'appointments_doctor_id_appointment_datetime_key')) {
            throw Exception(
                "This appointment slot seems to be already booked. Please try another time.");
          } else if (detailsString.contains('notifications_pkey')) {
            debugPrint(
                "[BookAppointment] WARNING: Duplicate notification ID collision (UUID).");

          } else {
            throw Exception(
                "Failed to book appointment due to a data conflict. Please try again.");
          }
        } else if (error.code == '23502') {
          // not-null violation
          debugPrint(
              "[BookAppointment] CRITICAL: Not-null constraint violation during booking. Check data being sent. Error: $error");
          throw Exception(
              "Failed to save appointment data. Required information might be missing.");
        } else {
          throw Exception(
              "Failed to book appointment. Database error occurred (Code: ${error.code}). Please try again later.");
        }
      } else {

        debugPrint("[BookAppointment] Generic Insert Error: $error");
        throw Exception(
            "Failed to book appointment. Please check your connection and try again.");
      }

      return false;
    }

  }

  Future<List<Map<String, dynamic>>> getAvailableDoctors() async {
    try {
      final response = await supabase
          .from('doctors')
          .select(
              'id, title, first_name, last_name, specialty') 
          .order('last_name', ascending: true);


      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("[GetAvailableDoctors] Error fetching doctors: $e");
      throw Exception("Failed to fetch doctors.");
    }
  }

  Future<List<String>> getDoctorAvailability(
      String doctorId, DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    debugPrint(
        "[GetAvailability] Fetching for Doctor ID: $doctorId on Date: $formattedDate");

    try {

      final availabilityResponse = await supabase
          .from('availability')
          .select('start_time, end_time')
          .inFilter('status',
              ['active', 'available']) 
          .eq('doctor_id', doctorId)
          .eq('available_date', formattedDate)
          .order('start_time', ascending: true);

      debugPrint(
          "[GetAvailability] Availability Records Found: ${availabilityResponse.length}");
      if (availabilityResponse.isEmpty) {
        return []; // No general availability defined for this day
      }

      
      final List<String> potentialSlots = [];
      final timeFormatter = DateFormat('h:mm a'); // Display format
      final timeParser = DateFormat('HH:mm:ss'); // DB format parser

      for (var slotData in availabilityResponse) {
        final startTimeString = slotData['start_time'] as String?;
        final endTimeString = slotData['end_time'] as String?;
        if (startTimeString != null && endTimeString != null) {
          try {
            final parsedStartTime = timeParser.parseStrict(startTimeString);
            final parsedEndTime = timeParser.parseStrict(endTimeString);
            DateTime currentSlotTime = DateTime(date.year, date.month, date.day,
                parsedStartTime.hour, parsedStartTime.minute);
            DateTime slotEndTime = DateTime(date.year, date.month, date.day,
                parsedEndTime.hour, parsedEndTime.minute);
            if (!slotEndTime.isAfter(currentSlotTime))
              continue; // Skip if end is not after start
            while (currentSlotTime.isBefore(slotEndTime)) {
              potentialSlots.add(timeFormatter.format(currentSlotTime));
              currentSlotTime = currentSlotTime
                  .add(const Duration(minutes: 15)); // Assuming 15-min slots
            }
          } catch (e) {
            debugPrint(
                "[GetAvailability] ERROR parsing time range: start='$startTimeString', end='$endTimeString'. Error: $e");
          }
        }
      }
      debugPrint(
          "[GetAvailability] Generated ${potentialSlots.length} potential slots: $potentialSlots");

   
      final bookedResponse = await supabase
          .from('appointments')
          .select(
              'appointment_time') // Select the time column (assuming HH:mm:ss format)
          .eq('doctor_id', doctorId)
          .eq('appointment_date', formattedDate)
          // Filter out cancelled/completed appointments - ONLY check 'upcoming'
          .eq('appointment_status', 'upcoming');
   

      debugPrint(
          "[GetAvailability] Booked Appointments Found: ${bookedResponse.length}");


      final Set<String> bookedTimesSet = {};
      if (bookedResponse.isNotEmpty) {
        for (var booking in bookedResponse) {
          final bookedTimeString =
              booking['appointment_time'] as String?; // e.g., "10:45:00"
          if (bookedTimeString != null) {
            try {
              // Parse the booked time (HH:mm:ss)
              final parsedBookedTime = timeParser.parseStrict(bookedTimeString);
              // Create a DateTime just for formatting
              final bookedDateTime = DateTime(date.year, date.month, date.day,
                  parsedBookedTime.hour, parsedBookedTime.minute);
              // Format it to 'h:mm a'
              bookedTimesSet.add(timeFormatter.format(bookedDateTime));
            } catch (e) {
              debugPrint(
                  "[GetAvailability] ERROR parsing booked time '$bookedTimeString': $e");
            }
          }
        }
      }
      debugPrint("[GetAvailability] Formatted booked times: $bookedTimesSet");

      final List<String> finalAvailableSlots = potentialSlots
          .where((slot) => !bookedTimesSet.contains(slot))
          .toList();


      try {
        finalAvailableSlots.sort((a, b) => timeFormatter
            .parseStrict(a)
            .compareTo(timeFormatter.parseStrict(b)));
      } catch (e) {
        debugPrint(
            "[GetAvailability] Error sorting final times: $e. Returning unsorted list.");
      }

      debugPrint(
          "[GetAvailability] Final ${finalAvailableSlots.length} available slots after filtering: $finalAvailableSlots");
      return finalAvailableSlots;
    } catch (e) {
      debugPrint(
          "[GetAvailability] CRITICAL ERROR fetching/filtering availability: $e");
      throw Exception(
          "Failed to fetch doctor's availability. Please try again later.");
    }
  }
}