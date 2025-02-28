import 'package:flutter/material.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/patient_dashboard/dashboard.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});
  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.primaryColor
      ,
      appBar: AppBar(
        backgroundColor: AppPallete.primaryColor,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: AppPallete.whiteColor,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
              );
            },
          ),
        ),
      ),
      body: Center(
        child: SafeArea(
          child: Container(
            width: 288,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'HOME',
                    style: TextStyle(fontSize: 15, color: AppPallete.whiteColor,fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                  },
                ),
                ListTile(
                  title: Text(
                    'MEDICAL RECORDS',
                    style: TextStyle(fontSize: 15, color: AppPallete.whiteColor,fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                  },
                ),
                ListTile(
                  title: Text(
                    'MEDICAL REMINDERS',
                    style: TextStyle(fontSize: 15, color: AppPallete.whiteColor,fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                  },
                ),
                ListTile(
                  title: Text(
                    'HEALTH ARTICLES',
                    style: TextStyle(fontSize: 15, color: AppPallete.whiteColor,fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                  },
                ),
                ListTile(
                  title: Text(
                    'VACCINATION REMINDERS',
                    style: TextStyle(fontSize: 15, color: AppPallete.whiteColor,fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                  },
                ),
                ListTile(
                  title: Text(
                    'BOOKINGS',
                    style: TextStyle(fontSize: 15, color: AppPallete.whiteColor,fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                  },
                ),
                ListTile(
                  title: Text(
                    'DOCTORS',
                    style: TextStyle(fontSize: 15, color: AppPallete.whiteColor,fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                  },
                ),
                ListTile(
                  title: Text(
                    'SETTINGS',
                    style: TextStyle(fontSize: 15, color: AppPallete.whiteColor,fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
