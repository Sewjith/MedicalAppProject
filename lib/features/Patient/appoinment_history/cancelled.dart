//@annotate:modification:lib/features/Patient/appoinment_history/cancelled.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
// Import the DB logic from appoinment.dart (or the separate file if created)
import 'package:medical_app/features/Patient/appoinment_history/appoinment.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Renamed widget
class CancelledAppointmentsList extends StatefulWidget {
  const CancelledAppointmentsList({super.key});

  @override
  State<CancelledAppointmentsList> createState() =>
      _CancelledAppointmentsListState();
}

class _CancelledAppointmentsListState extends State<CancelledAppointmentsList> {
  // Use the embedded DB class instance
  final AppointmentHistoryDb _db = AppointmentHistoryDb();
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _patientId;

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
      final data = await _db.getCancelledAppointments(_patientId!);
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
      return const Center(child: Text('No cancelled appointments.'));
    }

    // Return only the ListView
    return ListView.builder(
      padding: const EdgeInsets.all(16.0), // Add padding
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        final doctorData = appointment['doctor'] as Map<String, dynamic>?;
        final doctorName = _db.getDoctorDisplayName(doctorData);
        final specialty = doctorData?['specialty'] ?? 'N/A';
        final avatarUrl = _db.getDoctorAvatarUrl(doctorData);

        // Use a common card widget structure
        return Card(
          color: Colors.red.shade50, // Different color for cancelled
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 1,
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
                                  color: AppPallete.textColor)),
                          Text(specialty,
                              style:
                                  const TextStyle(color: AppPallete.greyColor)),
                          Text(
                              _db.formatAppointmentDateTime(
                                  appointment['appointment_date'],
                                  appointment['appointment_time']),
                              style: const TextStyle(
                                  color: AppPallete.greyColor, fontSize: 13)),
                          // Optionally display cancellation reason if available
                          if (appointment['cancellation_reason'] != null &&
                              appointment['cancellation_reason'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                "Reason: ${appointment['cancellation_reason']}",
                                style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.whiteColor,
                          foregroundColor: AppPallete.primaryColor),
                      onPressed: () {
                        // Navigate to Re-book flow (e.g., doctor profile)
                        if (doctorData?['id'] != null) {
                          context.go('/patient/doctors/profile_view',
                              extra: doctorData!['id'].toString());
                        }
                      },
                      child: const Text("Re-Book"),
                    ),
                    // Optionally add a button to leave feedback/review even for cancelled
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primaryColor),
                      onPressed: () {
                        // Navigate to Add Review page using GoRouter
                        context.push('/patient/appointment/history/review2',
                            extra: {
                              'appointmentId': appointment['appointment_id'],
                              'doctorName': doctorName,
                              'specialty': specialty,
                              'avatarUrl': avatarUrl,
                            });
                      },
                      child: const Text("Leave Feedback",
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
