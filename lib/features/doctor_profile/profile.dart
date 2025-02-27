import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor_profile/pages/settings.dart';
import 'package:medical_app/features/doctor_profile/pages/terms_and_conditions.dart';
import 'package:medical_app/features/doctor_profile/pages/privacy_and_policy.dart';
import 'package:medical_app/features/doctor_profile/pages/edit_profile.dart';
import 'package:medical_app/core/bottom_nav_bar.dart';
void main(){
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Placeholder()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Placeholder()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Placeholder()),
        );
        break;
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
            style: TextStyle(fontWeight: FontWeight.bold,
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
          icon: Icon(
            Icons.arrow_back_ios_new_sharp, color: AppPallete.primaryColor,),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Placeholder()));
          },
        ),
        title: Text(
          'My Profile',
          style: TextStyle(color: AppPallete.headings,
              fontWeight: FontWeight.bold,
              fontSize: 35),
        ),
        centerTitle: true,

      ),
      body:
      Column(
        children: [
          SizedBox(height: 30),
          CircleAvatar(radius: 75,
            backgroundImage: AssetImage('assets/images/doctor.jpg'),),
          SizedBox(height: 2),
          Text(
            'Dr. AAAA',
            style: TextStyle(fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppPallete.textColor),
          ),
          Text(
            'Cardiologist',
            style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppPallete.textColor),
          ),
          SizedBox(height: 35),
          Expanded(child: Center(child:
          ListView(
            children: [
              buildMenuItem(Icons.person, "Profile", context),
              buildMenuItem(Icons.calendar_today, "Appointments", context),
              buildMenuItem(Icons.payment, "Earnings and Payments", context),
              buildMenuItem(Icons.lock, "Privacy Policy", context),
              buildMenuItem(
                  Icons.document_scanner_outlined, "Terms & Conditions",
                  context),
              buildMenuItem(Icons.settings, "Settings", context),
              buildMenuItem(Icons.help_outline, "Help", context),
              buildMenuItem(Icons.logout, "Logout", context),
            ],
          ),
          ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const editProfile()));
        }
        if (text == "Settings") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const settings()));
        }
        if (text == "Privacy Policy") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const PrivacyPage()));
        }
        if (text == "Terms & Conditions") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const TermsPage()));
        }
        if (text == "Logout") {
          _showLogoutDialog(context);
        }
      },
    );
  }
}
