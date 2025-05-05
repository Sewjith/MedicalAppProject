import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/themes/color_palette.dart';


class SideMenu extends StatefulWidget {
  const SideMenu({super.key});
  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppPallete.primaryColor,

        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppPallete.whiteColor),
            onPressed: () {

              Navigator.pop(context);

            },
          ),
        ),
      ),
      body: SafeArea(
          child: Container(
            width: 288,
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.home_outlined, color: AppPallete.whiteColor),
                  title: const Text(
                    'HOME',
                    style: TextStyle(fontSize: 16, color: AppPallete.whiteColor, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/p_dashboard');
                  },
                ),
                 ListTile(
                   leading: const Icon(Icons.folder_copy_outlined, color: AppPallete.whiteColor),
                   title: const Text(
                     'MEDICAL RECORDS',
                     style: TextStyle(fontSize: 16, color: AppPallete.whiteColor, fontWeight: FontWeight.w500),
                   ),
                   onTap: () {
                     Navigator.pop(context);
                     context.go('/patient/health-record');
                   },
                 ),
                 ListTile(
                   leading: const Icon(Icons.alarm, color: AppPallete.whiteColor),
                   title: const Text(
                     'MEDICATION REMINDERS',
                     style: TextStyle(fontSize: 16, color: AppPallete.whiteColor, fontWeight: FontWeight.w500),
                   ),
                   onTap: () {
                      Navigator.pop(context);
                      context.go('/medication-reminder');
                   },
                 ),
                  ListTile(
                    leading: const Icon(Icons.monitor_heart_outlined, color: AppPallete.whiteColor), // Changed Icon
                    title: const Text(
                      'SYMPTOM TRACKER', // Added Text
                      style: TextStyle(fontSize: 16, color: AppPallete.whiteColor, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/symptom-tracker'); // Added Navigation
                    },
                  ),
                  ListTile(
                   leading: const Icon(Icons.article_outlined, color: AppPallete.whiteColor),
                   title: const Text(
                     'HEALTH ARTICLES', // Renamed from HEALTH ARTICLES
                     style: TextStyle(fontSize: 16, color: AppPallete.whiteColor, fontWeight: FontWeight.w500),
                   ),
                   onTap: () {
                     Navigator.pop(context);
                     context.go('/patient/articles'); // Navigate to patient article list
                   },
                 ),
                  ListTile(
                   leading: const Icon(Icons.vaccines_outlined, color: AppPallete.whiteColor),
                   title: const Text(
                     'VACCINATION REMINDERS',
                     style: TextStyle(fontSize: 16, color: AppPallete.whiteColor, fontWeight: FontWeight.w500),
                   ),
                   onTap: () {
                      Navigator.pop(context);
                      context.go('/medication-reminder/vaccination'); // Updated route based on router.dart
                   },
                 ),
                 ListTile(
                   leading: const Icon(Icons.book_online_outlined, color: AppPallete.whiteColor),
                   title: const Text(
                     'BOOKINGS',
                     style: TextStyle(fontSize: 16, color: AppPallete.whiteColor, fontWeight: FontWeight.w500),
                   ),
                   onTap: () {
                     Navigator.pop(context);
                     context.go('/patient/appointment/history');
                   },
                 ),
                  ListTile(
                   leading: const Icon(Icons.search_outlined, color: AppPallete.whiteColor),
                   title: const Text(
                     'DOCTORS',
                     style: TextStyle(fontSize: 16, color: AppPallete.whiteColor, fontWeight: FontWeight.w500),
                   ),
                   onTap: () {
                     Navigator.pop(context);
                     context.go('/patient/doctors/search');
                   },
                 ),
                 // Add Doctor Finder ListTile
                 ListTile(
                   leading: const Icon(Icons.chat_bubble_outline, color: AppPallete.whiteColor), // Chatbot icon
                   title: const Text(
                     'FIND A DOCTOR', // Changed text for clarity
                     style: TextStyle(fontSize: 16, color: AppPallete.whiteColor, fontWeight: FontWeight.w500),
                   ),
                   onTap: () {
                     Navigator.pop(context); // Close drawer
                     context.push('/chatbot'); // Navigate to the chatbot route
                   },
                 ),
                 const Divider(color: AppPallete.whiteColor),
                 ListTile(
                   leading: const Icon(Icons.settings_outlined, color: AppPallete.whiteColor),
                   title: const Text(
                     'SETTINGS',
                     style: TextStyle(fontSize: 16, color: AppPallete.whiteColor, fontWeight: FontWeight.w500),
                   ),
                   onTap: () {
                     Navigator.pop(context);
                     context.go('/patient/profile/settings');
                   },
                 ),
                 ListTile(
                   leading: const Icon(Icons.logout_outlined, color: AppPallete.whiteColor),
                   title: const Text(
                     'LOGOUT',
                     style: TextStyle(fontSize: 16, color: AppPallete.whiteColor, fontWeight: FontWeight.w500),
                   ),
                   onTap: () {
                     Navigator.pop(context);

                     context.go('/login');
                   },
                 ),
              ],
            ),
          ),
        ),
    );
  }
}