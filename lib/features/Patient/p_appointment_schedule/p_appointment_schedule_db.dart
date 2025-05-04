//@annotate:modification:lib/features/Patient/p_appointment_schedule/p_appointment_schedule_db.dart
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart'; // Ensure Uuid is imported
import 'package:intl/intl.dart'; // Import intl for date/time formatting

class DatabaseService {
  final supabase = Supabase.instance.client;
  final _uuid = const Uuid(); // UUID generator instance

  // --- bookAppointment method modified for return type satisfaction ---
  Future<bool> bookAppointment({
    required String patientId,
    required String doctorId,
    required String problemDesc,
    required DateTime date,
    required String time, // Expects formatted time string like "9:30 AM"
    required String patientName,
    required int patientAge,
    required String patientGender,
    // Added doctorName for notification message
    required String doctorName,
  }) async {
    String? bookedAppointmentId; // To store the ID of the booked appointment

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      DateTime parsedSelectedTime;
      try {
         parsedSelectedTime = DateFormat('h:mm a').parseStrict(time);
      } catch (e) {
         debugPrint("[BookAppointment] FATAL Error parsing time string '$time': $e");
         throw Exception("Invalid time format selected ($time). Cannot proceed.");
      }
      final DateTime appointmentDateTime = DateTime(
          date.year, date.month, date.day,
          parsedSelectedTime.hour, parsedSelectedTime.minute,
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

      debugPrint("[BookAppointment] Attempting to insert appointment data: $insertData");
      await supabase.from('appointments').insert(insertData);
      debugPrint("[BookAppointment] Appointment booked successfully with ID: $bookedAppointmentId.");

      // --- Add Notification Record ---
      try {
          // Generate UUID for the notification ID
          final notificationUuid = _uuid.v4();

          // Format the date part of the message for clarity (e.g., "May 04")
          final formattedAppointmentDate = DateFormat('MMM dd').format(date);
          final notificationMessage = "Reminder: Your appointment with $doctorName is scheduled for $formattedAppointmentDate at $time.";

          final notificationData = {
             // Add the generated notification_id
             'notification_id': notificationUuid,
             'receiver_id': patientId,
             'receiver_type': 'patient', // Target the patient
             'message': notificationMessage,
             'type': 'appointment_reminder', // Specific type for appointment reminders
             'reference_id': bookedAppointmentId, // Link to the appointment record
             'reference_type': 'appointment',
             'read_status': false, // Default read status to false
             'created_at': DateTime.now().toIso8601String(), // Ensure created_at is set
          };
          debugPrint("[BookAppointment] Attempting to insert notification data: $notificationData");
          await supabase.from('notifications').insert(notificationData);
          debugPrint("[BookAppointment] Notification record created successfully with ID: $notificationUuid.");
      } catch (notificationError) {
         // Log the error but don't fail the whole booking if notification insert fails
         debugPrint("[BookAppointment] WARNING: Failed to create notification record: $notificationError");
         // Optionally, rethrow if notification is critical:
         // throw Exception("Failed to create notification record.");
      }
      // --- End Add Notification Record ---

      return true; // Appointment booked (notification attempt logged)

    } catch (error) {
      if (error is PostgrestException) {
         debugPrint("[BookAppointment] PostgrestException: code=${error.code}, message=${error.message}, details=${error.details}, hint=${error.hint}");

         // Safely check error.details as String before using .contains
         String detailsString = '';
         if (error.details is String) {
             detailsString = error.details as String;
         } else if (error.details != null) {
             // If details is not null but not a string, convert it safely
             detailsString = error.details.toString();
         }

         // Specific error handling based on code and details string
         if (error.code == '23505') { // unique constraint violation
            if (detailsString.contains('appointments_pkey') || detailsString.contains('appointments_doctor_id_appointment_datetime_key')) {
              throw Exception("This appointment slot seems to be already booked. Please try another time.");
            } else if (detailsString.contains('notifications_pkey')) {
               debugPrint("[BookAppointment] WARNING: Duplicate notification ID collision (UUID).");
               // This case is unlikely here, but if needed, decide whether to throw or allow booking to proceed.
               // For now, just log and let booking proceed if appointment was saved.
               // If we want to fail the booking, throw here:
               // throw Exception("Failed to save notification details. Please try booking again.");
            } else {
               throw Exception("Failed to book appointment due to a data conflict. Please try again.");
            }
         } else if (error.code == '23502') { // not-null violation
             debugPrint("[BookAppointment] CRITICAL: Not-null constraint violation during booking. Check data being sent. Error: $error");
             throw Exception("Failed to save appointment data. Required information might be missing.");
         } else {
           throw Exception("Failed to book appointment. Database error occurred (Code: ${error.code}). Please try again later.");
         }
      } else {
         // Non-Postgrest error (network, parsing, etc.)
         debugPrint("[BookAppointment] Generic Insert Error: $error");
         throw Exception("Failed to book appointment. Please check your connection and try again.");
      }
       // **Add return false here to satisfy the compiler's non-null return path analysis**
       // This line should not be reached if exceptions are thrown correctly above.
       return false;
    }
    // **Ensure a return path exists even outside the main try-catch (although unlikely to be reached)**
    // return false; // This is likely redundant if the catch block always throws or returns.
  }

  // --- getAvailableDoctors method remains the same ---
  Future<List<Map<String, dynamic>>> getAvailableDoctors() async {
    try {
       final response = await supabase
           .from('doctors')
           .select('id, title, first_name, last_name, specialty') // Ensure 'id' is included
           .order('last_name', ascending: true);

       // Convert response to the expected format if needed, ensure 'id' is present
       return List<Map<String, dynamic>>.from(response);
    } catch (e) {
       debugPrint("[GetAvailableDoctors] Error fetching doctors: $e");
       throw Exception("Failed to fetch doctors.");
    }
  }

  // --- getDoctorAvailability method remains the same ---
  Future<List<String>> getDoctorAvailability(String doctorId, DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    debugPrint("[GetAvailability] Fetching for Doctor ID: $doctorId on Date: $formattedDate");

    try {
      // 1. Get Doctor's General Availability Ranges for the day
      final availabilityResponse = await supabase
          .from('availability')
          .select('start_time, end_time')
          .inFilter('status', ['active', 'available']) // Ensure status filter is correct
          .eq('doctor_id', doctorId)
          .eq('available_date', formattedDate)
          .order('start_time', ascending: true);

      debugPrint("[GetAvailability] Availability Records Found: ${availabilityResponse.length}");
      if (availabilityResponse.isEmpty) {
        return []; // No general availability defined for this day
      }

      // 2. Generate all potential 15-min slots from the ranges
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
             DateTime currentSlotTime = DateTime(date.year, date.month, date.day, parsedStartTime.hour, parsedStartTime.minute);
             DateTime slotEndTime = DateTime(date.year, date.month, date.day, parsedEndTime.hour, parsedEndTime.minute);
             if (!slotEndTime.isAfter(currentSlotTime)) continue; // Skip if end is not after start
             while (currentSlotTime.isBefore(slotEndTime)) {
               potentialSlots.add(timeFormatter.format(currentSlotTime));
               currentSlotTime = currentSlotTime.add(const Duration(minutes: 15)); // Assuming 15-min slots
             }
           } catch (e) {
              debugPrint("[GetAvailability] ERROR parsing time range: start='$startTimeString', end='$endTimeString'. Error: $e");
           }
        }
      }
      debugPrint("[GetAvailability] Generated ${potentialSlots.length} potential slots: $potentialSlots");

      // 3. Get Already Booked Appointment Times for that doctor/date
      final bookedResponse = await supabase
          .from('appointments')
          .select('appointment_time') // Select the time column (assuming HH:mm:ss format)
          .eq('doctor_id', doctorId)
          .eq('appointment_date', formattedDate)
          // Filter out cancelled/completed appointments - ONLY check 'upcoming'
          .eq('appointment_status', 'upcoming');
          // Add other statuses if needed: .inFilter('appointment_status', ['upcoming', 'confirmed'])

      debugPrint("[GetAvailability] Booked Appointments Found: ${bookedResponse.length}");

      // 4. Create a Set of booked times formatted as 'h:mm a' for efficient lookup
      final Set<String> bookedTimesSet = {};
      if (bookedResponse.isNotEmpty) {
        for (var booking in bookedResponse) {
           final bookedTimeString = booking['appointment_time'] as String?; // e.g., "10:45:00"
           if (bookedTimeString != null) {
             try {
                // Parse the booked time (HH:mm:ss)
                final parsedBookedTime = timeParser.parseStrict(bookedTimeString);
                // Create a DateTime just for formatting
                final bookedDateTime = DateTime(date.year, date.month, date.day, parsedBookedTime.hour, parsedBookedTime.minute);
                // Format it to 'h:mm a'
                bookedTimesSet.add(timeFormatter.format(bookedDateTime));
             } catch (e) {
                debugPrint("[GetAvailability] ERROR parsing booked time '$bookedTimeString': $e");
             }
           }
        }
      }
       debugPrint("[GetAvailability] Formatted booked times: $bookedTimesSet");

      // 5. Filter potential slots, removing those that are already booked
      final List<String> finalAvailableSlots = potentialSlots
          .where((slot) => !bookedTimesSet.contains(slot))
          .toList();

      // Optional: Sort the final list (though it should be mostly sorted)
      try {
          finalAvailableSlots.sort((a, b) => timeFormatter.parseStrict(a).compareTo(timeFormatter.parseStrict(b)));
      } catch(e) {
         debugPrint("[GetAvailability] Error sorting final times: $e. Returning unsorted list.");
      }

      debugPrint("[GetAvailability] Final ${finalAvailableSlots.length} available slots after filtering: $finalAvailableSlots");
      return finalAvailableSlots;

    } catch (e) {
      debugPrint("[GetAvailability] CRITICAL ERROR fetching/filtering availability: $e");
      throw Exception("Failed to fetch doctor's availability. Please try again later.");
    }
  }
}