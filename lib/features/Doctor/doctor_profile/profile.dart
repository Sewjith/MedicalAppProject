import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/core/common/cubits/user_session/app_user_cubit.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor/doctor_profile/pages/settings.dart';
import 'package:medical_app/features/doctor/doctor_profile/pages/terms_and_conditions.dart';
import 'package:medical_app/features/doctor/doctor_profile/pages/privacy_and_policy.dart';
// Remove direct import of edit_profile, navigation handled by GoRouter
// import 'package:medical_app/features/doctor/doctor_profile/pages/edit_profile.dart';
import 'package:medical_app/features/doctor/doctor_profile/profile_db.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medical_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter


class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileDB _profileDB = ProfileDB();
  Map<String, dynamic>? doctorData;
  String? _currentDoctorId;
  bool _isLoading = true;
  String? _errorMessage;


  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDoctorIdAndFetchProfile();
    });
  }

  void _initializeDoctorIdAndFetchProfile() {
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserLoggedIn && userState.user.role == 'doctor') {
      setState(() {
        _currentDoctorId = userState.user.uid;
        _isLoading = true;
        _errorMessage = null;
      });
      if (_currentDoctorId != null) {
        _fetchDoctorProfile();
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


  Future<void> _fetchDoctorProfile() async {
    if (_currentDoctorId == null || !mounted) return;
    if (!_isLoading) setState(() => _isLoading = true);

    try {
      final data = await _profileDB.getDoctorProfile(_currentDoctorId!);
       if (!mounted) return;
      setState(() {
        doctorData = data;
        _isLoading = false;
      });
    } catch (e) {
       if (!mounted) return;
      setState(() {
          _isLoading = false;
          _errorMessage = "Error loading profile: ${e.toString()}";
          doctorData = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!)),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppPallete.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Logout",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppPallete.primaryColor,
                fontSize: 22),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: TextStyle(fontSize: 17, color: AppPallete.textColor),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50]),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(
                  color: AppPallete.primaryColor, fontSize: 15)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthSignOut());
                context.go('/login');
              },
              child: Text("Yes, Logout",
                  style: TextStyle(fontSize: 15, color: AppPallete.whiteColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppPallete.whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppPallete.primaryColor),
          onPressed: () {
             if(context.canPop()) {
               context.pop();
             } else {
               context.go('/d_dashboard');
             }
          }
        ),
        title: Text(
          'My Profile',
          style: TextStyle(
              color: AppPallete.headings,
              fontWeight: FontWeight.bold,
              fontSize: 35),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
             ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!, style: TextStyle(color: Colors.red))))
             : doctorData == null
                ? Center(child: Text('Could not load profile data.'))
                : Column(
                   children: [
                     SizedBox(height: 30),
                     CircleAvatar(
                       radius: 75,
                       backgroundColor: Colors.grey[200],
                       backgroundImage: doctorData!['avatar_url'] != null
                           ? CachedNetworkImageProvider(doctorData!['avatar_url'])
                           : AssetImage('assets/images/doctor.jpg') as ImageProvider,
                     ),
                     SizedBox(height: 2),
                     Text(
                       '${doctorData!['title'] ?? ''} ${doctorData!['first_name'] ?? ''} ${doctorData!['last_name'] ?? ''}'.trim(),
                       style: TextStyle(
                           fontSize: 28,
                           fontWeight: FontWeight.bold,
                           color: AppPallete.textColor),
                     ),
                     Text(
                       doctorData!['specialty'] ?? 'Specialty Not Set',
                       style: TextStyle(
                           fontSize: 18,
                           fontWeight: FontWeight.bold,
                           color: AppPallete.textColor),
                     ),
                     SizedBox(height: 35),
                     Expanded(
                       child: Center(
                         child: ListView(
                           children: [
                             buildMenuItem(Icons.person, "Profile", context),
                             buildMenuItem(Icons.calendar_today, "Appointments", context),
                             buildMenuItem(Icons.payment, "Earnings and Payments", context),
                             buildMenuItem(Icons.lock, "Privacy Policy", context),
                             buildMenuItem(
                                 Icons.document_scanner_outlined, "Terms & Conditions", context),
                             buildMenuItem(Icons.settings, "Settings", context),
                             buildMenuItem(Icons.help_outline, "Help", context),
                             buildMenuItem(Icons.logout, "Logout", context),
                           ],
                         ),
                       ),
                     ),
                   ],
                 ),
    );
  }

  Widget buildMenuItem(IconData icon, String text, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppPallete.primaryColor, size: 38),
      title: Text(
        text,
        style: TextStyle(fontSize: 19, color: AppPallete.textColor),
      ),
      trailing: Icon(
        Icons.chevron_right, color: AppPallete.greyColor, size: 35,),
      onTap: () {
        if (text == "Profile") {
           if (doctorData != null && _currentDoctorId != null) {
              // Use context.push with extra map for GoRouter navigation
              context.push(
                 '/doctor/profile/edit',
                 extra: {
                   'doctorData': doctorData!,
                   'doctorId': _currentDoctorId!,
                   'onProfileUpdated': _fetchDoctorProfile, // Pass callback if needed
                 },
              );
           } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile data not loaded yet.')),
                );
           }
        }
        if (text == "Settings") {
           context.go('/doctor/profile/settings');
        }
        if (text == "Privacy Policy") {
            context.go('/doctor/profile/settings/privacy');
        }
        if (text == "Terms & Conditions") {
           context.go('/doctor/profile/settings/terms');
        }
        if (text == "Logout") {
          _showLogoutDialog(context);
        }
        if (text == "Appointments") {
           context.go('/doctor/appointment/schedule');
        }
         if (text == "Earnings and Payments") {
           context.go('/doctor/earnings');
        }
      },
    );
  }
}