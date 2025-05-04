//@annotate:modification:lib/features/Patient/appoinment_history/upcoming.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
// Import the DB logic from appoinment.dart (or the separate file if created)
import 'package:medical_app/features/Patient/appoinment_history/appoinment.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Renamed widget
class UpcomingAppointmentsList extends StatefulWidget {
  const UpcomingAppointmentsList({super.key});

  @override
  State<UpcomingAppointmentsList> createState() =>
      _UpcomingAppointmentsListState();
}

class _UpcomingAppointmentsListState extends State<UpcomingAppointmentsList> {
  // Use the embedded DB class instance
  final AppointmentHistoryDb _db = AppointmentHistoryDb();
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _patientId;

  // Keep track of deleted items for undo functionality (optional)
  Map<String, dynamic>? _lastCancelledAppointment;

  @override
  void initState() {
    super.initState();
    // Fetch patientId and load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = context.read<AppUserCubit>().state;
      if (userState is AppUserLoggedIn && userState.user.role == 'patient') {
        _patientId = userState.user.uid;
        _loadAppointments();
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Patient not logged in.";
          });
        }
      }
    });
  }

  Future<void> _loadAppointments() async {
    if (_patientId == null || !mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _db.getUpcomingAppointments(_patientId!);
      if (mounted) {
        setState(() {
          _appointments = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
        });
      }
    }
  }

  // Navigate to Cancel Form using GoRouter
  void _navigateToCancelForm(String appointmentId) {
    context.push('/patient/appointment/history/cancel-form',
        extra: appointmentId);
    // Note: After cancellation on the form page, this list should ideally refresh.
    // This might require passing a callback or using a state management solution
    // that notifies this list when an appointment status changes.
    // For now, we'll rely on manual refresh or revisiting the page.
  }

  // Navigate to Details Page using GoRouter
  void _navigateToDetails(Map<String, dynamic> appointment) {
    final doctorData = appointment['doctor'] as Map<String, dynamic>?;
    final doctorName = _db.getDoctorDisplayName(doctorData);
    final specialty = doctorData?['specialty'] ?? 'N/A';
    final dateStr = appointment['appointment_date'];
    final timeStr = appointment['appointment_time'];
    final displayDateTime = _db.formatAppointmentDateTime(dateStr, timeStr);
    // Split displayDateTime for the details page if it expects separate date/time
    final parts = displayDateTime.split('•');
    final displayDate = parts.isNotEmpty ? parts[0].trim() : 'N/A';
    final displayTime = parts.length > 1 ? parts[1].trim() : 'N/A';

    context.push('/patient/appointment/history/details', extra: {
      'doctorName': doctorName,
      'specialty': specialty,
      'appointmentDate': displayDate, // Pass formatted date
      'appointmentTime': displayTime, // Pass formatted time
      // Pass any other needed data
    });
  }

  @override
  Widget build(BuildContext context) {
    // REMOVED Scaffold, AppBar, BottomNavBar

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }
    if (_appointments.isEmpty) {
      return const Center(child: Text('No upcoming appointments.'));
    }

    // Return only the ListView
    return ListView.builder(
      padding: const EdgeInsets.all(16.0), // Add padding
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        final paymentStatus =
            appointment['Payment Status'] as String? ?? 'unknown';
        final bool needsPayment = paymentStatus.toLowerCase() == 'pending';
        final doctorData = appointment['doctor'] as Map<String, dynamic>?;
        final doctorName = _db.getDoctorDisplayName(doctorData);
        final specialty = doctorData?['specialty'] ?? 'N/A';
        final avatarUrl = _db.getDoctorAvatarUrl(doctorData);

        // Use a common card widget structure
        return Card(
          color: Colors.blue.shade50, // Different color for upcoming
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: avatarUrl != null
                          ? CachedNetworkImageProvider(avatarUrl)
                          : const AssetImage(
                                  'assets/images/doctor_placeholder.png')
                              as ImageProvider,
                      onBackgroundImageError: (_, __) {
                        debugPrint("Error loading image: $avatarUrl");
                      },
                      child: avatarUrl == null
                          ? const Icon(Icons.person,
                              size: 30, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctorName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppPallete
                                      .primaryColor)), // Adjusted color
                          Text(specialty,
                              style:
                                  const TextStyle(color: AppPallete.textColor)),
                          Text(
                              _db.formatAppointmentDateTime(
                                  appointment['appointment_date'],
                                  appointment['appointment_time']),
                              style: const TextStyle(
                                  color: AppPallete.textColor, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly, // Adjust button spacing
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _navigateToCancelForm(appointment['appointment_id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.whiteColor,
                        foregroundColor:
                            Colors.redAccent, // Red text for cancel
                        side: const BorderSide(
                            color: Colors.redAccent), // Red border
                      ),
                      child: const Text("Cancel"),
                    ),
                    // Conditionally add Pay Now Button
                    if (needsPayment)
                      ElevatedButton(
                        onPressed: () {
                          final String appointmentId =
                              appointment['appointment_id'];
                          // Navigate to payment page, passing the ID
                          debugPrint(
                              "Navigating to payment for Appointment ID: $appointmentId"); // Optional debug print
                          context.push('/payment', extra: appointmentId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green, // Or your preferred payment color
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Pay Now"),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        final String appointmentId =
                            appointment['appointment_id']; // Get the ID
                        context.push('/patient/appointment/history/cancel-form',
                            extra: appointmentId); // Pass as extra
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primaryColor),
                      child: const Text("Details",
                          style: TextStyle(color: AppPallete.whiteColor)),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
