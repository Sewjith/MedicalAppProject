import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/Doctor/doctor_profile/profile_db.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ProfileDB _profileDB = ProfileDB();
  final AppointmentService _appointmentService =
      AppointmentService(Supabase.instance.client);
  String? _currentDoctorId;
  Map<String, dynamic>? _doctorData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDoctorData();
    });
  }

  void _initializeDoctorData() {
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn && userState.user.role == 'doctor') {
      setState(() {
        _currentDoctorId = userState.user.uid;
        _isLoading = true;
        _errorMessage = null;
      });
      if (_currentDoctorId != null) {
        _loadDoctorData(_currentDoctorId!);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Could not retrieve doctor ID.";
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "User is not logged in as a doctor.";
      });
    }
  }

  Future<void> _loadDoctorData(String doctorId) async {
    try {
      final data = await _profileDB.getDoctorProfile(doctorId);
      if (mounted) {
        setState(() {
          _doctorData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading doctor data: $_errorMessage')),
        );
      }
    }
  }

  Future<void> _showTodayAppointments() async {
    if (_currentDoctorId == null) return;

    try {
      final today = DateTime.now();
      final appointments = await _appointmentService.getDoctorAppointments(
          _currentDoctorId!, today);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Today's Appointments"),
          content: appointments.isEmpty
              ? const Text("No appointments for today.")
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      final time = appointment['appointment_time'] ?? 'N/A';
                      final patient = appointment['patient_name'] ?? 'Unknown';
                      final status = appointment['status'] ?? 'scheduled';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(patient),
                          subtitle: Text('Time: $time'),
                          trailing: Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: status == 'completed'
                                    ? Colors.green
                                    : status == 'cancelled'
                                        ? Colors.red
                                        : Colors.orange,
                              ),
                            ),
                            backgroundColor: Colors.grey[200],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading appointments: ${e.toString()}')),
      );
    }
  }

  Widget drawerItem(String title, String routePath, BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: AppPallete.whiteColor,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        context.go(routePath);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.secondaryColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppPallete.primaryColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.notifications, color: AppPallete.primaryColor),
            onPressed: _showTodayAppointments,
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: AppPallete.primaryColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: AppPallete.primaryColor),
                child: Text(
                  "MENU",
                  style: TextStyle(
                    fontSize: 24,
                    color: AppPallete.whiteColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              drawerItem("OVERVIEW", '/doctor/overview', context),
              drawerItem("PATIENT LIST", '/doctor/patient-list', context),
              drawerItem("INBOX", '/doctor/inbox', context),
              drawerItem("SCHEDULE", '/doctor/appointment/schedule', context),
              drawerItem("AVAILABILITY", '/doctor/availability', context),
              drawerItem("PRESCRIPTIONS", '/doctor/prescription-tool', context),
              drawerItem("MY ARTICLES", '/doctor/articles', context),
              drawerItem("EARNINGS", '/doctor/earnings', context),
              drawerItem("CONSULTATION HISTORY", '/doctor/consultation-history',
                  context),
              drawerItem("PROFILE", '/doctor/profile', context),
            ],
          ),
        ),
      ),
      body: BlocBuilder<AppUserCubit, AppUserState>(
        builder: (context, state) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: $_errorMessage'),
              ),
            );
          }
          if (state is! AppUserLoggedIn ||
              state.user.role != 'doctor' ||
              _doctorData == null) {
            return const Center(child: Text("Please log in as a doctor."));
          }

          final firstName = _doctorData?['first_name'] ?? 'Doctor';
          final lastName = _doctorData?['last_name'] ?? '';
          final title = _doctorData?['title'] ?? 'Dr.';
          final specialty = _doctorData?['specialty'] ?? 'Specialist';
          final fullName = '$title $firstName $lastName'.trim();
          final avatarUrl = _doctorData?['avatar_url'] as String?;

          return Container(
            color: AppPallete.secondaryColor,
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  decoration: const BoxDecoration(
                    color: AppPallete.primaryColor,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hi ! $firstName',
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.whiteColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 30,
                          color: AppPallete.whiteColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 100,
                          backgroundColor: AppPallete.whiteColor,
                          backgroundImage: (avatarUrl != null
                                  ? NetworkImage(avatarUrl)
                                  : const AssetImage(
                                      'assets/images/doctor1.jpg'))
                              as ImageProvider,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.textColor,
                          ),
                        ),
                        Text(
                          specialty,
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppPallete.greyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AppointmentService {
  final SupabaseClient _supabase;

  AppointmentService(this._supabase);

  Future<List<Map<String, dynamic>>> getDoctorAppointments(
      String doctorId, DateTime selectedDate) async {
    try {
      final startDate =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endDate = startDate.add(const Duration(days: 1));

      final response = await _supabase
          .from('appointments')
          .select('''
            appointment_id,
            appointment_datetime,
            status,
            notes,
            patient_name,
            patient_age,
            patient_gender,
            appointment_time
          ''')
          .eq('doctor_id', doctorId)
          .gte('appointment_datetime', startDate.toIso8601String())
          .lt('appointment_datetime', endDate.toIso8601String())
          .order('appointment_time', ascending: true);

      if (response.isNotEmpty) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch appointments: $e');
    }
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      await _supabase
          .from('appointments')
          .update({'status': status}).eq('appointment_id', appointmentId);
    } catch (e) {
      throw Exception('Failed to update appointment status: $e');
    }
  }
}
