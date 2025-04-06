import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor-search/data/model/doctor_list_model.dart';

class DoctorProfile extends StatefulWidget {
  final DoctorListModel profile;

  const DoctorProfile({super.key, required this.profile});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  static const String defaultImageUrl = "assets/images/defaultProfile.webp";
  static const String defaultExperience = "2"; 

  @override
  Widget build(BuildContext context) {
    final String profileImage = defaultImageUrl;
    final String experience =  defaultExperience;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Info', style: TextStyle(color: AppPallete.headings)),
        leading: BackButton(
          onPressed: () {
            context.go('/doctor-profiles');
          },
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 80,
                            backgroundImage: AssetImage(profileImage),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppPallete.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "$experience years \nExperience",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppPallete.headings,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Focus: \n  random",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${widget.profile.firstName} ${widget.profile.lastName}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.primaryColor,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),
              const Text(
                "RandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandom",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: AppPallete.textColor,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              const Text(
                "Career Paths",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.primaryColor,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),
              const Text(
                "RandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandom",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: AppPallete.textColor,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              const Text(
                "Highlights",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.primaryColor,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),
              const Text(
                "RandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandom",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: AppPallete.textColor,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
