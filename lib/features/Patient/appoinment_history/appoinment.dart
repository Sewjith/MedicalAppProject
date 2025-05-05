import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/Patient/appoinment_history/upcoming.dart'; 
import 'package:medical_app/features/Patient/appoinment_history/cancelled.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:cached_network_image/cached_network_image.dart'; 
import 'package:flutter/foundation.dart';


class AppointmentHistoryDb {
  final _supabase = Supabase.instance.client;

 
  Future<Map<String, dynamic>> getAppointmentDetails(
      String appointmentId) async {
    if (appointmentId.isEmpty) {
      throw Exception('Appointment ID cannot be empty.');
    }
    try {

      final appointmentResponse = await _supabase
          .from('appointments')
          .select('''
            id,
            appointment_id,
            appointment_date,
            appointment_time,
            appointment_status,
            "Payment Status",
            notes,
            patient_name,
            patient_age,
            patient_gender,
            doctor:doctor_id (
              id,
              title,
              first_name,
              last_name,
              specialty,
              gender,
              avatar_path
            )
          ''')
          .eq('appointment_id', appointmentId) 
          .maybeSingle();


      if (appointmentResponse == null) {
        throw Exception('Appointment not found.');
      }


      if (appointmentResponse['doctor'] != null &&
          appointmentResponse['doctor']['avatar_path'] != null) {
        try {
          final url = _supabase.storage
              .from('Doctor Avatars')
              .getPublicUrl(appointmentResponse['doctor']['avatar_path']);
          appointmentResponse['doctor']['avatar_url'] = url;
        } catch (e) {
          debugPrint(
              "Error getting avatar URL for doctor ${appointmentResponse['doctor']['id']}: $e");
          appointmentResponse['doctor']['avatar_url'] = null;
        }
      } else {
        if (appointmentResponse['doctor'] != null) {
          appointmentResponse['doctor']['avatar_url'] = null;
        }
      }

      final String? appointmentUUID = appointmentResponse['id'] as String?;
      String? prescriptionPdfUrl;

      if (appointmentUUID != null && appointmentUUID.isNotEmpty) {
        try {
          final prescriptionResponse = await _supabase
              .from('prescriptions')
              .select('pdf_url')
              .eq('appointment_id', appointmentUUID) 
              .maybeSingle(); 

          if (prescriptionResponse != null &&
              prescriptionResponse['pdf_url'] != null) {
            prescriptionPdfUrl = prescriptionResponse['pdf_url'] as String?;
          }
        } catch (e) {
          debugPrint(
              "Error fetching prescription for appointment UUID $appointmentUUID: $e");
      
        }
      } else {
        debugPrint(
            "Appointment primary key 'id' (UUID) not found or empty for appointment_id $appointmentId.");
      }

      appointmentResponse['prescription_pdf_url'] = prescriptionPdfUrl;


      return appointmentResponse; // Return the combined data
    } catch (e) {
      debugPrint("Error fetching appointment details for $appointmentId: $e");
      if (e is PostgrestException) {
        debugPrint("Supabase Error Details: ${e.message}");
        throw Exception('Database error while fetching details: ${e.message}');
      }
      throw Exception('Failed to load appointment details.');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAppointmentsByStatus(
      String patientId, List<String> statuses) async {
    try {

      final response = await _supabase
          .from('appointments')
          .select('''
            appointment_id,
            appointment_date,
            appointment_time,
            appointment_status,
            "Payment Status",
            doctor:doctor_id (
              id,
              title,
              first_name,
              last_name,
              specialty,
              gender,
              avatar_path
            )
          ''')

          .eq('patient_id', patientId)
          .inFilter('appointment_status', statuses)
          .order('appointment_date', ascending: true)
          .order('appointment_time', ascending: true);

      for (var appointment in response) {
        if (appointment['doctor'] != null &&
            appointment['doctor']['avatar_path'] != null) {
          try {
            final url = _supabase.storage
                .from('Doctor Avatars') 
                .getPublicUrl(appointment['doctor']['avatar_path']);
            appointment['doctor']['avatar_url'] = url;
          } catch (e) {
            debugPrint(
                "Error getting avatar URL for doctor ${appointment['doctor']['id']}: $e");
            appointment['doctor']['avatar_url'] = null;
          }
        } else {
          if (appointment['doctor'] != null) {
            appointment['doctor']['avatar_url'] = null;
          }
        }
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching appointments with status $statuses: $e");
      if (e is PostgrestException && e.code == '42703') {
        debugPrint(
            "DB Schema Error: A column referenced in the query does not exist.");
        throw Exception('Database schema mismatch. Please contact support.');
      }
      throw Exception('Failed to load appointments.');
    }
  }


  Future<List<Map<String, dynamic>>> getCompletedAppointments(
      String patientId) async {
    return _fetchAppointmentsByStatus(patientId, ['completed']);
  }

  Future<List<Map<String, dynamic>>> getUpcomingAppointments(
      String patientId) async {
    return _fetchAppointmentsByStatus(patientId, ['upcoming']);
  }

  Future<List<Map<String, dynamic>>> getCancelledAppointments(
      String patientId) async {
    return _fetchAppointmentsByStatus(patientId, ['cancelled']);
  }

  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {

      final appointmentData = await _supabase
          .from('appointments')
          .select('id')
          .eq('appointment_id',
              appointmentId) 
          .maybeSingle();

      if (appointmentData == null || appointmentData['id'] == null) {
        throw Exception('Cannot find appointment to cancel.');
      }
      final String appointmentUUID = appointmentData['id'];

-
      await _supabase.from('appointments').update({
        'appointment_status': 'cancelled',
      }).eq('id', appointmentUUID); 

    } catch (e) {
      debugPrint("Error cancelling appointment $appointmentId: $e");
      if (e is PostgrestException) {
        debugPrint("Supabase Error Details: ${e.message}");
        throw Exception(
            'Database error while cancelling appointment: ${e.message}');
      }
      throw Exception('Failed to cancel appointment.');
    }
  }

  String formatAppointmentDateTime(String? dateStr, String? timeStr) {
    if (dateStr == null) return 'Date N/A';
    try {
      final date = DateTime.parse(dateStr);
      String formattedDate =
          DateFormat('EEE, MMM dd, yyyy').format(date); // Use yyyy for year
      String formattedTime = 'Time N/A';
      if (timeStr != null) {
        try {
          final parsedTime = DateFormat('HH:mm:ss').parseStrict(timeStr);
          formattedTime = DateFormat('h:mm a').format(parsedTime);
        } catch (e) {
          formattedTime = timeStr; // Fallback if parsing fails
          debugPrint("Could not parse time '$timeStr' for display");
        }
      }
      return '$formattedDate • $formattedTime';
    } catch (e) {
      debugPrint("Could not parse date '$dateStr'");
      return 'Invalid Date';
    }
  }

  String getDoctorDisplayName(Map<String, dynamic>? doctorData) {
    if (doctorData == null) return 'Unknown Doctor';
    return '${doctorData['title'] ?? ''} ${doctorData['first_name'] ?? ''} ${doctorData['last_name'] ?? ''}'
        .trim();
  }

  String? getDoctorAvatarUrl(Map<String, dynamic>? doctorData) {
    return doctorData?['avatar_url'] as String?;
  }
}



class AppointmentHistoryPage extends StatefulWidget {
  final int initialTabIndex;
  const AppointmentHistoryPage({super.key, this.initialTabIndex = 1});

  @override
  State<AppointmentHistoryPage> createState() => _AppointmentHistoryPageState();
}

class _AppointmentHistoryPageState extends State<AppointmentHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Appointments',
          style: TextStyle(
            color: AppPallete.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppPallete.whiteColor,
        elevation: 1,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppPallete.primaryColor,
          unselectedLabelColor: AppPallete.greyColor,
          indicatorColor: AppPallete.primaryColor,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'Completed'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CompletedAppointmentsList(),
          UpcomingAppointmentsList(),
          CancelledAppointmentsList(),
        ],
      ),
    );
  }
}


class _CompletedAppointmentsList extends StatefulWidget {
  const _CompletedAppointmentsList();

  @override
  State<_CompletedAppointmentsList> createState() =>
      _CompletedAppointmentsListState();
}

class _CompletedAppointmentsListState
    extends State<_CompletedAppointmentsList> {
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
      final data = await _db.getCompletedAppointments(_patientId!);
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
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Text('Error: $_errorMessage', textAlign: TextAlign.center)));
    }
    if (_appointments.isEmpty) {
      return const Center(
          child: Text('No completed appointments found.',
              style: TextStyle(color: AppPallete.greyColor)));
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          final doctorData = appointment['doctor'] as Map<String, dynamic>?;
          final doctorName = _db.getDoctorDisplayName(doctorData);
          final specialty = doctorData?['specialty'] ?? 'N/A';
          final avatarUrl = _db.getDoctorAvatarUrl(doctorData);

          return Card(
            color: Colors.grey.shade100,
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
                                    color: AppPallete.textColor)),
                            Text(specialty,
                                style: const TextStyle(
                                    color: AppPallete.greyColor)),
                            Text(
                                _db.formatAppointmentDateTime(
                                    appointment['appointment_date'],
                                    appointment['appointment_time']),
                                style: const TextStyle(
                                    color: AppPallete.greyColor, fontSize: 13)),
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
                        child: const Text("Add Review",
                            style: TextStyle(color: AppPallete.whiteColor)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppPallete.primaryColor, // Match upcoming style
                   
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
      ),
    );
  }
}
