import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/Patient/patient_profile/pages/settings.dart';
import 'package:medical_app/features/Patient/patient_profile/pages/edit_profile.dart';
import 'package:medical_app/features/Patient/patient_profile/patient_db.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PatientProfile extends StatelessWidget {
  const PatientProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PatientProfilePage(),
    );
  }
}

class PatientProfilePage extends StatefulWidget {
  @override
  _PatientProfilePageState createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  int _selectedIndex = 2;
  final PatientDB _patientDB = PatientDB();
  final String patientId = "a0945ec7-b0b8-4672-95a7-29b6da1b6587"; 
  Map<String, dynamic>? patientData;

  @override
  void initState() {
    super.initState();
    _fetchPatientProfile();
  }

  Future<void> _fetchPatientProfile() async {
    try {
      final data = await _patientDB.getPatientProfile(patientId);
      setState(() {
        patientData = data;
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
      body: patientData == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SizedBox(height: 30),
          CircleAvatar(
            radius: 75,
            backgroundColor: Colors.grey[200],
            backgroundImage: patientData!['avatar_url'] != null
                ? CachedNetworkImageProvider(patientData!['avatar_url'])
                : AssetImage('assets/images/patient.jpg') as ImageProvider,
          ),
          SizedBox(height: 2),
          Text(
            '${patientData!['first_name']} ${patientData!['last_name']}',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppPallete.textColor),
          ),
          Text(
            'Patient',
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
                  buildMenuItem(Icons.medical_services, "Medical Records", context),
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
              builder: (context) => PatientEditProfilePage(
                patientData: patientData!,
                onProfileUpdated: _fetchPatientProfile,
              ),
            ),
          );
        }
        if (text == "Settings") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PatientSettingsPage()),
          );
        }
        
        if (text == "Logout") {
          _showLogoutDialog(context);
        }
      },
    );
  }
}