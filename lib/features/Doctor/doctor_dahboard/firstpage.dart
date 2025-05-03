import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart'; // Import Cubit
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/Doctor/doctor_profile/profile_db.dart'; // Use ProfileDB

// Removed imports for screens navigated to via GoRouter
// import 'package:medical_app/features/doctor/doctor_dahboard/appoinment.dart'; // (Now uses GoRouter)
// import 'package:medical_app/features/doctor/doctor_dahboard/patient_list.dart'; // (Now uses GoRouter)
// import 'package:medical_app/features/doctor/doctor_dahboard/inbox.dart'; // (Now uses GoRouter)
// import 'package:medical_app/features/doctor/doctor_dahboard/earnings.dart'; // (Now uses GoRouter)
// import 'package:medical_app/features/doctor/doctor_dahboard/overview.dart'; // (Now uses GoRouter)
// Removed unused import
// import 'package:supabase_flutter/supabase_flutter.dart';

// Removed the StatelessWidget wrapper DoctorDashboard

class DashboardScreen extends StatefulWidget {
  // Removed doctorId parameter - will fetch internally
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Use ProfileDB from doctor_profile feature
  final ProfileDB _profileDB = ProfileDB();
  String? _currentDoctorId;
  Map<String, dynamic>? _doctorData;
  bool _isLoading = true;
  String? _errorMessage;

  // Removed hover state variables and selectedIndex

  @override
  void initState() {
    super.initState();
    // Fetch data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDoctorData();
    });
  }

  // Fetches doctor ID from Cubit and loads data
  void _initializeDoctorData() {
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn && userState.user.role == 'doctor') {
      setState(() {
        _currentDoctorId = userState.user.uid; // Get doctor ID (uid)
        _isLoading = true; // Set loading before fetch
        _errorMessage = null; // Clear previous errors
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
        // Optionally redirect: context.go('/login');
      });
    }
  }

  // Fetches doctor data using ProfileDB
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

  // Simplified drawer item without hover state
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
        Navigator.pop(context); // Close the drawer
        context.go(routePath); // Navigate using GoRouter
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar managed by MainLayout if needed, or keep simple one here
      appBar: AppBar(
        backgroundColor: AppPallete.secondaryColor,
        elevation: 0,
        // Menu icon to open drawer
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppPallete.primaryColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton( // Navigate to Notifications
            icon: const Icon(Icons.notifications, color: AppPallete.primaryColor),
             onPressed: () {
               if (_currentDoctorId != null) {
                 context.go('/notifications', extra: {
                   'receiverId': _currentDoctorId!,
                   'receiverType': 'doctor'
                 });
               }
             },
          ),
        ],
      ),
      // Drawer for navigation
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
                  style: TextStyle(fontSize: 24, color: AppPallete.whiteColor, fontWeight: FontWeight.bold), // Added bold
                ),
              ),
              // Use context.go for navigation
              drawerItem("OVERVIEW", '/doctor/overview', context),
              //drawerItem("PATIENT LIST", '/doctor/patients', context),
              drawerItem("PATIENT LIST", '/doctor/patient-list', context),
              drawerItem("INBOX", '/doctor/inbox', context),
              drawerItem("SCHEDULE", '/doctor/appointment/schedule', context),
              drawerItem("AVAILABILITY", '/doctor/availability', context),
              drawerItem("PRESCRIPTIONS", '/doctor/prescription-tool', context),
              drawerItem("MY ARTICLES", '/doctor/articles', context),
              drawerItem("EARNINGS", '/doctor/earnings', context),
              drawerItem("CONSULTATION HISTORY", '/doctor/consultation-history', context),
              drawerItem("PROFILE", '/doctor/profile', context),
              // Add other relevant items like Settings if needed
            ],
          ),
        ),
      ),
      body: BlocBuilder<AppUserCubit, AppUserState>( // Rebuild on auth state changes
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
          if (state is! AppUserLoggedIn || state.user.role != 'doctor' || _doctorData == null) {
             return const Center(child: Text("Please log in as a doctor."));
          }

          // Extract data safely after checks
          final firstName = _doctorData?['first_name'] ?? 'Doctor';
          final lastName = _doctorData?['last_name'] ?? '';
          final title = _doctorData?['title'] ?? 'Dr.';
          final specialty = _doctorData?['specialty'] ?? 'Specialist';
          final fullName = '$title $firstName $lastName'.trim();
          final avatarUrl = _doctorData?['avatar_url'] as String?; // Get avatar URL

          // Main content when data is loaded
          return Container(
            color: AppPallete.secondaryColor, // Background color
            padding: const EdgeInsets.only(bottom: 16.0), // Padding at the bottom
            child: Column( // Use Column instead of nested Containers
              children: [
                // Top section with gradient/color
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30), // Adjusted padding
                  decoration: const BoxDecoration(
                    color: AppPallete.primaryColor,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hi ! $firstName',
                        style: const TextStyle(
                          fontSize: 38, // Adjusted size
                          fontWeight: FontWeight.bold,
                          color: AppPallete.whiteColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 30, // Adjusted size
                          color: AppPallete.whiteColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Profile section below the colored header
                Expanded( // Allow the profile section to take remaining space
                 child: SingleChildScrollView( // Make profile scrollable if needed
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                       mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                       children: [
                          CircleAvatar(
                           radius: 100, // Adjusted size
                           backgroundColor: AppPallete.whiteColor,
                           // Use fetched avatar URL or default
                           backgroundImage: (avatarUrl != null
                               ? NetworkImage(avatarUrl)
                               : const AssetImage('assets/images/doctor1.jpg')) as ImageProvider,
                          ),
                          const SizedBox(height: 15),
                          Text(
                           fullName,
                           style: const TextStyle(
                             fontSize: 28, // Adjusted size
                             fontWeight: FontWeight.bold,
                             color: AppPallete.textColor,
                           ),
                          ),
                          Text(
                           specialty,
                           style: const TextStyle(
                             fontSize: 20, // Adjusted size
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
