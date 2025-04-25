import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/patient/patient_profile/pages/notifications.dart';
import 'package:medical_app/features/patient/patient_profile/pages/change_password.dart';
import 'package:medical_app/features/patient/patient_profile/pages/delete_account.dart';

class PatientSettingsPage extends StatelessWidget {
  const PatientSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppPallete.whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppPallete.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 35, color: AppPallete.headings, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 35),
          Expanded(child: Center(
            child: ListView(
              children: [
                buildMenuItem(Icons.lightbulb_outline, "Notification Settings", context),
                buildMenuItem(Icons.key_outlined, "Password Manager", context),
                buildMenuItem(Icons.person_outline, "Delete Account", context),
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
        style: TextStyle(fontSize: 19),
      ),
      trailing: Icon(Icons.chevron_right_outlined, color: AppPallete.greyColor, size: 30),
      onTap: (){
        if (text == "Notification Settings") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
        }
        if (text == "Password Manager") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
        }
        if (text == "Delete Account") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DeleteAccountScreen()));
        }
      },
    );
  }
}