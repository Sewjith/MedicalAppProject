import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:go_router/go_router.dart'; // Import GoRouter for navigation
import 'package:intl/intl.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart'; // Import Cubit
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/patient/patient_dashboard/menu_nav.dart';
import 'package:medical_app/features/patient/patient_dashboard/dashboard_db.dart';
import 'package:medical_app/features/patient/patient_dashboard/pages/doctor_search.dart';
import 'package:medical_app/features/Patient/doctor-search/data/model/doctor_list_model.dart'; 



class DashboardScreen extends StatefulWidget {
 

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardDB _dashboardDB = DashboardDB();

  String? _currentPatientId; // Store the dynamic patient ID
  String patientFirstName = 'Patient'; // Default name
  bool isLoading = true; // General loading state for initial setup
  String? errorMessage;

  Map<String, dynamic>? upcomingAppointment;
  List<Map<String, dynamic>> availableDoctors = [];
  bool doctorsLoading = true;
  bool appointmentLoading = true;

  @override
  void initState() {
    super.initState();
    // Defer loading until the first frame is built and context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePatientData();
    });
  }

  // Fetches patient ID from Cubit and loads data
  void _initializePatientData() {
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn && userState.user.role == 'patient') {
      setState(() {
         _currentPatientId = userState.user.uid; // Get patient ID (uid)
         isLoading = true; // Set loading true before fetching data
      });
      if (_currentPatientId != null) {
        _loadInitialData(_currentPatientId!);
      } else {
         // Handle case where ID is unexpectedly null
         setState(() {
            isLoading = false;
            errorMessage = "Could not retrieve patient ID.";
         });
      }
    } else {
      // Handle cases where user is not logged in or not a patient
      setState(() {
        isLoading = false;
        errorMessage = "User is not logged in as a patient.";
        // Optionally, redirect to login: context.go('/login');
      });
    }
  }


  // accept patientId
  Future<void> _loadInitialData(String patientId) async {
    // Ensure the initial loading state is set correctly
     if (!isLoading) { // Check if loading state needs resetting
       setState(() {
         isLoading = true;
         appointmentLoading = true;
         doctorsLoading = true;
         errorMessage = null; // Clear previous errors
       });
     }

    try {
      // Fetch data concurrently
      final results = await Future.wait([
        _dashboardDB.getPatientFirstName(patientId),
        _dashboardDB.getUpcomingAppointment(patientId),
        // Fetch all doctors
        _dashboardDB.searchDoctors(''), // Fetch all doctors initially
      ]);

      // Safely update state if the widget is still mounted
      if (mounted) {
         setState(() {
          patientFirstName = results[0] as String;
          upcomingAppointment = results[1] as Map<String, dynamic>?;
          // Cast the result correctly
          availableDoctors = List<Map<String, dynamic>>.from(results[2] as List);
          isLoading = false; // Overall loading done
          doctorsLoading = false;
          appointmentLoading = false;
        });
      }

    } catch (e) {
       if (mounted) {
         setState(() {
          isLoading = false;
          doctorsLoading = false;
          appointmentLoading = false;
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard data: $errorMessage')),
        );
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to reactively display content based on auth state
    return BlocBuilder<AppUserCubit, AppUserState>(
      builder: (context, state) {
        // Show loading indicator until patient ID is confirmed and initial data load starts/completes
        if (_currentPatientId == null && isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Show error if user is not a logged-in patient or data loading failed
        if (state is! AppUserLoggedIn || state.user.role != 'patient' || errorMessage != null) {
           return Scaffold(
             appBar: AppBar(title: const Text("Error")),
             drawer: const Drawer(child: SideMenu()), // Still show drawer for potential navigation
             body: Center(
               child: Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Text(errorMessage ?? "Access denied. Please log in as a patient."),
               ),
             ),
           );
        }

        // Main dashboard content once patient ID is available
        return Scaffold(
          drawer: const Drawer(child: SideMenu()),
          backgroundColor: AppPallete.whiteColor,
          body: SafeArea(
            child: RefreshIndicator( // Add pull-to-refresh
              onRefresh: () async {
                 if (_currentPatientId != null) {
                   await _loadInitialData(_currentPatientId!);
                 }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Ensure scroll physics for RefreshIndicator
                child: Column(
                  children: [
                    _buildHeaderSection(),
                    _buildSearchSection(),
                    _buildQuickAccessSection(),
                    _buildUpcomingAppointmentSection(),
                    _buildAvailableDoctorsSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          // Add Floating Action Button for Chatbot
          floatingActionButton: FloatingActionButton(
             onPressed: () => context.push('/chatbot'), // Navigate to chatbot route
             tooltip: 'Find a Doctor',
             backgroundColor: AppPallete.primaryColor,
             child: const Icon(Icons.chat_bubble_outline, color: AppPallete.whiteColor),
          ),
        );
      },
    );
  }


  Widget _buildHeaderSection() {
    // Access first name fetched in _loadInitialData
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder( // Ensure context for Scaffold.of is correct
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppPallete.textColor),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundImage: AssetImage('assets/images/patient.jpeg'), // Consider making this dynamic
              ),
              const SizedBox(width: 7),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hi, Welcome Back',
                    style: TextStyle(
                      fontSize: 17,
                      color: AppPallete.headings,
                    ),
                  ),
                  Text(
                    patientFirstName, // Use fetched name
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppPallete.textColor,
                      fontWeight: FontWeight.bold // Make name bold
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton( // Navigate to Notifications
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppPallete.textColor,
            ),
             onPressed: () {
               if (_currentPatientId != null) {
                 context.go('/notifications', extra: {
                   'receiverId': _currentPatientId!,
                   'receiverType': 'patient'
                 });
               }
             },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Column(
            children: [
              IconButton(
                onPressed: () {
                   // Ensure patientId is available before navigating
                   if (_currentPatientId != null) {
                     // Navigate using GoRouter and pass patientId
                     context.go('/patient/doctors/favorites', extra: _currentPatientId);
                   } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Please wait, loading user data...')),
                     );
                   }
                },
                icon: const Icon(
                  Icons.favorite_border_outlined,
                  color: AppPallete.primaryColor,
                  size: 30,
                ),
              ),
              const Text(
                'Favorite',
                style: TextStyle(
                  fontSize: 14,
                  color: AppPallete.headings,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              readOnly: true, // Make TextField non-editable, taps trigger search
              onTap: () async {
                // Use the search delegate for doctor search
                final selectedDoctor = await showSearch<Map<String, dynamic>?>(
                  context: context,
                  delegate: DoctorSearchDelegate(dashboardDB: _dashboardDB),
                );
                if (selectedDoctor != null) {
                   // Navigate to doctor profile view
                    // Create a DoctorListModel from the map
                    final doctorModel = DoctorListModel(
                        id: selectedDoctor['id'] ?? '',
                        firstName: selectedDoctor['firstName'] ?? '',
                        lastName: selectedDoctor['lastName'] ?? '',
                        specialty: selectedDoctor['specialty'] ?? '',
                        // Assuming number and email might not be in search results,
                        // provide defaults or fetch them if needed on the profile page
                        number: selectedDoctor['number'] ?? 'N/A',
                        email: selectedDoctor['email'] ?? 'N/A',
                    );
                   context.go('/patient/doctors/profile_view', extra: doctorModel);
                }
              },
              decoration: InputDecoration(
                hintText: 'Search doctors...',
                prefixIcon: const Icon(Icons.search_outlined),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildQuickAccessSection() {
    // These can be made dynamic later if needed
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Added vertical padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _QuickAccessButton(
            icon: Icons.medical_services_outlined,
            label: 'Doctor',
            onTap: () => context.go('/patient/doctors/search'), // Navigate to doctor search
          ),
          _QuickAccessButton(
            icon: Icons.local_pharmacy_rounded,
            label: 'Pharmacy',
            onTap: () {
               // TODO: Add navigation for Pharmacy
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Pharmacy section not yet implemented')),
               );
            },
          ),
          _QuickAccessButton(
            icon: Icons.local_hospital_rounded,
            label: 'Hospital',
             onTap: () {
               // TODO: Add navigation for Hospital
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Hospital section not yet implemented')),
               );
            },
          ),
          _QuickAccessButton(
            icon: Icons.local_hospital_outlined, // Consider a better icon like Icons.emergency
            label: 'Ambulance',
             onTap: () => context.go('/emergency-assistance'), // Navigate to emergency
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align title left
        children: [
          const SizedBox(height: 10), // Reduced space
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Add space-between
            children: [
              const Text(
                'Upcoming Schedule',
                style: TextStyle(
                  fontSize: 20, // Slightly smaller font
                  color: AppPallete.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell( // Make "See All" tappable
                 onTap: () => context.go('/patient/appointment/history'),
                 child: const Text(
                   'See All',
                   style: TextStyle(
                     fontSize: 14,
                     color: AppPallete.primaryColor,
                     fontWeight: FontWeight.w500,
                   ),
                 ),
               ),
            ],
          ),
          const SizedBox(height: 10),
          _buildAppointmentCard(),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard() {
    // Show loading indicator while appointment data is loading
    if (appointmentLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Show message if no upcoming appointment
    if (upcomingAppointment == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20), // Add padding
        child: const Center(
          child: Text(
           'No upcoming appointments',
           style: TextStyle(fontSize: 16, color: AppPallete.greyColor),
          ),
        ),
      );
    }

    // Extract appointment details safely
    final doctor = upcomingAppointment!['doctor'] as Map<String, dynamic>? ?? {};
    final appointmentDateStr = upcomingAppointment!['appointment_date'] as String?;
    final appointmentTime = upcomingAppointment!['appointment_time'] as String? ?? 'N/A';
    final appointmentId = upcomingAppointment!['id'] as String? ?? ''; // Get appointment ID for call
    DateTime? appointmentDate;
    String formattedDate = 'N/A';

    if (appointmentDateStr != null) {
       try {
         appointmentDate = DateTime.parse(appointmentDateStr);
         formattedDate = DateFormat('EEEE, MMMM d').format(appointmentDate);
       } catch (e) {
         formattedDate = 'Invalid Date'; // Handle parsing error
       }
    }

    // Build the card UI
    return Container(
      width: double.infinity,
      // height: 200, // Let height be dynamic
      decoration: BoxDecoration(
        color: AppPallete.headings,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppPallete.greyColor,
            spreadRadius: 2, // Reduced spread
            blurRadius: 5, // Reduced blur
            offset: Offset(0, 2), // Reduced offset
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar( // Use a default or fetch dynamically
                  radius: 35, // Slightly smaller
                  backgroundImage: AssetImage('assets/images/doctor.jpg'), // TODO: Fetch doctor avatar if available
                ),
                const SizedBox(width: 10), // Increased space
                Expanded( // Allow text to wrap
                  child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       '${doctor['title'] ?? ''} ${doctor['first_name'] ?? ''} ${doctor['last_name'] ?? 'Unknown Doctor'}'.trim(),
                       style: const TextStyle(
                         fontSize: 18, // Adjusted font size
                         color: AppPallete.whiteColor,
                         fontWeight: FontWeight.bold,
                       ),
                       overflow: TextOverflow.ellipsis, // Prevent overflow
                     ),
                      Text(
                       doctor['specialty'] ?? 'Unknown Specialty',
                       style: const TextStyle(
                         fontSize: 15, // Adjusted font size
                         color: AppPallete.whiteColor,
                       ),
                        overflow: TextOverflow.ellipsis,
                     ),
                      const SizedBox(height: 6),
                      Text(
                       '$formattedDate • $appointmentTime',
                       style: const TextStyle(
                         fontSize: 14, // Adjusted font size
                         color: AppPallete.whiteColor,
                       ),
                     ),
                   ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15), // Increased spacing
            Row( // Align button to the right
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon( // Use ElevatedButton.icon
                   onPressed: () {
                     // TODO: Fetch actual Agora App ID and Token dynamically
                     const appId = "bc06bf6bab7645abbc9b9d56db3f2868"; // Placeholder
                     const token = "007eJxTYLh7OefL0v7fU7e+81X30H74mZ369K6Jz993fT6/uMX+a84KDKZGhqkmhqlppoYWRhamxkbJyebJiUbGyeZJqUaGacmmzJ59SmsIZGTY8X9kYIRCEH4GRkYGJmZmlgaGADK+H/s="; // Placeholder/Temporary

                     if (appId.isEmpty || token.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Video call configuration missing.')),
                        );
                        return;
                     }
                     // Navigate to video call screen
                     context.go('/video-call', extra: {
                       'appId': appId,
                       'token': token,
                       'channelName': appointmentId, // Use appointment ID as channel name
                     });
                   },
                   icon: const Icon(Icons.video_call_rounded, color: AppPallete.primaryColor),
                   label: const Text(
                     'Join Call',
                     style: TextStyle(
                       fontSize: 16, // Adjusted font size
                       fontWeight: FontWeight.bold,
                       color: AppPallete.primaryColor,
                     ),
                   ),
                   style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8) // Adjusted padding
                   ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableDoctorsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align left
        children: [
          const SizedBox(height: 25), // Adjusted space
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Doctors', // Changed from "On Demand"
                style: TextStyle(
                  fontSize: 20, // Adjusted size
                  color: AppPallete.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell( // Make "See All" tappable
                onTap: () => context.go('/patient/doctors/search'), // Navigate to doctor search page
                child: const Text(
                   'See All',
                   style: TextStyle(
                     fontSize: 14,
                     color: AppPallete.primaryColor,
                     fontWeight: FontWeight.w500,
                   ),
                 ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDoctorsList(),
        ],
      ),
    );
  }

   Widget _buildDoctorsList() {
    // Show loading indicator
    if (doctorsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Show message if no doctors fetched
    if (availableDoctors.isEmpty) {
      return const Center(child: Text('No doctors available at the moment.'));
    }
    // Build list using ListView for better performance if list gets long
    return ListView.builder(
       shrinkWrap: true, // Important inside SingleChildScrollView
       physics: const NeverScrollableScrollPhysics(), // Disable internal scrolling
       itemCount: availableDoctors.length,
       itemBuilder: (context, index) {
          final doctor = availableDoctors[index];
          // Pass the dynamic patientId to the card
          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _DoctorCard(
              doctor: doctor,
              patientId: _currentPatientId!, // Pass the dynamic ID
              dashboardDB: _dashboardDB,
              onFavoriteChanged: () => setState(() {}), // Refresh state on change
            ),
          );
       }
    );
  }
} // End of _DashboardScreenState


// --- Quick Access Button Widget ---
class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap; // Add onTap callback

  const _QuickAccessButton({
    required this.icon,
    required this.label,
    this.onTap, // Make onTap optional
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onTap, // Use the provided onTap callback
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.grey.shade100, // Light background
            elevation: 2, // Subtle shadow
          ),
          child: Icon(
            icon,
            color: AppPallete.headings,
            size: 30,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13, // Slightly smaller label
            color: AppPallete.headings,
            fontWeight: FontWeight.w500, // Medium weight
          ),
        ),
      ],
    );
  }
}

// --- Doctor Card Widget ---
class _DoctorCard extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final String patientId; // Receive patientId
  final DashboardDB dashboardDB;
  final VoidCallback onFavoriteChanged;

  const _DoctorCard({
    required this.doctor,
    required this.patientId, // Require patientId
    required this.dashboardDB,
    required this.onFavoriteChanged,
  });

  @override
  State<_DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<_DoctorCard> {
  bool isFavorite = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // Checks favorite status using the dynamic patientId
  Future<void> _checkFavoriteStatus() async {
     if (!mounted) return; // Check if widget is still mounted
     setState(() => isLoading = true); // Start loading
    try {
      final status = await widget.dashboardDB.isDoctorFavorited(
        widget.patientId,
        widget.doctor['id'],
      );
      if (mounted) { // Check again before setting state
        setState(() {
          isFavorite = status;
          isLoading = false;
        });
      }
    } catch (e) {
       if (mounted) {
         setState(() {
            isLoading = false; // Stop loading even on error
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error checking favorite: ${e.toString().replaceFirst('Exception: ', '')}')),
          );
       }
    }
  }

  // Toggles favorite status using the dynamic patientId
  Future<void> _toggleFavorite() async {
     if (!mounted) return;
     setState(() => isLoading = true); // Show loading during update
    try {
      if (isFavorite) {
        await widget.dashboardDB.removeFavorite(
          widget.patientId,
          widget.doctor['id'],
        );
      } else {
        await widget.dashboardDB.addFavorite(
          widget.patientId,
          widget.doctor['id'],
        );
      }
       if (mounted) { // Check before setting state
         setState(() {
           isFavorite = !isFavorite;
           isLoading = false;
         });
         widget.onFavoriteChanged(); // Notify parent if needed
       }
    } catch (e) {
       if (mounted) {
          setState(() => isLoading = false); // Stop loading on error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating favorite: ${e.toString().replaceFirst('Exception: ', '')}')),
          );
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a DoctorListModel from the map for navigation
    final doctorModel = DoctorListModel(
      id: widget.doctor['id'] ?? '',
      firstName: widget.doctor['firstName'] ?? '',
      lastName: widget.doctor['lastName'] ?? '',
      specialty: widget.doctor['specialty'] ?? '',
      number: widget.doctor['number'] ?? 'N/A', // Provide default or fetch if needed
      email: widget.doctor['email'] ?? 'N/A', // Provide default or fetch if needed
    );

    return InkWell( // Wrap card in InkWell for tap detection
       onTap: () {
        final String? doctorId = widget.doctor['id'] as String?; // Extract ID as String
        if (doctorId != null && doctorId.isNotEmpty) {
          context.go('/patient/doctors/profile_view', extra: doctorId); // Pass ONLY the ID string
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not get doctor ID.')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12), // Reduced padding
        decoration: BoxDecoration(
          color: AppPallete.lightBackground, // Lighter background
          borderRadius: BorderRadius.circular(15),
          boxShadow: [ // Softer shadow
            BoxShadow(
              color: AppPallete.greyColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar( // Use default or fetch dynamically
              radius: 30, // Smaller avatar
              backgroundImage: AssetImage('assets/images/doctor.jpg'), // TODO: Fetch doctor avatar
            ),
            const SizedBox(width: 12), // Adjusted space
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.doctor['title'] ?? ''} ${widget.doctor['firstName'] ?? ''} ${widget.doctor['lastName'] ?? 'Doctor'}'.trim(),
                    style: const TextStyle(
                      fontSize: 16, // Adjusted size
                      fontWeight: FontWeight.bold,
                      color: AppPallete.primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.doctor['specialty'] ?? 'Specialty',
                    style: const TextStyle(
                      fontSize: 13, // Adjusted size
                      color: AppPallete.greyColor,
                    ),
                     overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Loading indicator or Favorite button
            isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : AppPallete.primaryColor, // Red when favorited
                      size: 24, // Adjusted size
                    ),
                    tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                  ),
          ],
        ),
      ),
    );
  }
}