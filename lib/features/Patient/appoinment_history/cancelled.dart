import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/Patient/appoinment_history/appoinment.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CancelledAppointmentsList extends StatefulWidget {
  const CancelledAppointmentsList({super.key});

  @override
  State<CancelledAppointmentsList> createState() =>
      _CancelledAppointmentsListState();
}

class _CancelledAppointmentsListState extends State<CancelledAppointmentsList> {
  final AppointmentHistoryDb _db = AppointmentHistoryDb();
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _patientId;

  @override
  void initState() {
    super.initState();
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }
    if (_appointments.isEmpty) {
      return const Center(child: Text('No cancelled appointments.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        final doctorData = appointment['doctor'] as Map<String, dynamic>?;
        final doctorName = _db.getDoctorDisplayName(doctorData);
        final specialty = doctorData?['specialty'] ?? 'N/A';
        final avatarUrl = _db.getDoctorAvatarUrl(doctorData);

        return Card(
          color: Colors.red.shade50,
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
                        if (doctorData?['id'] != null) {
                          context.go('/patient/doctors/profile_view',
                              extra: doctorData!['id'].toString());
                        }
                      },
                      child: const Text("Re-Book"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.primaryColor),
                      onPressed: () {
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppPallete.primaryColor, // Match upcoming style
                        // foregroundColor: AppPallete.whiteColor, // Set text color below
                      ),
                      onPressed: () {
                        final String? appointmentId =
                            appointment['appointment_id'];
                        if (appointmentId != null) {
                          context.push('/patient/appointment/history/details',
                              extra: appointmentId);
                        } else {
                          debugPrint(
                              "Error: Missing appointment_id for details");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Error: Could not get appointment ID.")),
                          );
                        }
                      },
                      child: const Text("Details",
                          style: TextStyle(
                              color: AppPallete.whiteColor)), // White text
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
