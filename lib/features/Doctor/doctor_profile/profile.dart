import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor/doctor_profile/pages/settings.dart';
import 'package:medical_app/features/doctor/doctor_profile/pages/terms_and_conditions.dart';
import 'package:medical_app/features/doctor/doctor_profile/pages/privacy_and_policy.dart';
import 'package:medical_app/features/doctor/doctor_profile/pages/edit_profile.dart';
import 'package:medical_app/features/doctor/doctor_profile/profile_db.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const Profile());
}

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
  int _selectedIndex = 2;
  final ProfileDB _profileDB = ProfileDB();
  final String doctorId = "79ee85c5-c5da-41f5-b4a0-579f4792f32f";
  Map<String, dynamic>? doctorData;

  @override
  void initState() {
    super.initState();
    _fetchDoctorProfile();
  }

  Future<void> _fetchDoctorProfile() async {
    try {
      final data = await _profileDB.getDoctorProfile(doctorId);
      setState(() {
        doctorData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
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
                print("Logging out...");
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
          onPressed: () => Navigator.pop(context),
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
      body: doctorData == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SizedBox(height: 30),
          // Updated CircleAvatar to use the URL from profile data
          CircleAvatar(
            radius: 75,
            backgroundColor: Colors.grey[200],
            backgroundImage: doctorData!['avatar_url'] != null
                ? CachedNetworkImageProvider(doctorData!['avatar_url'])
                : AssetImage('assets/images/doctor.jpg') as ImageProvider,
          ),
          SizedBox(height: 2),
          Text(
            '${doctorData!['title']} ${doctorData!['first_name']} ${doctorData!['last_name']}',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppPallete.textColor),
          ),
          Text(
            doctorData!['specialty'],
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(
                doctorData: doctorData!,
                onProfileUpdated: _fetchDoctorProfile,
              ),
            ),
          );
        }
        if (text == "Settings") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const settings()),
          );
        }
        if (text == "Privacy Policy") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrivacyPage()),
          );
        }
        if (text == "Terms & Conditions") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TermsPage()),
          );
        }
        if (text == "Logout") {
          _showLogoutDialog(context);
        }
      },
    );
  }
}