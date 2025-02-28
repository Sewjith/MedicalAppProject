import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor-search/domain/entities/doctor_profiles.dart';

class DoctorProfile extends StatefulWidget {
  final DoctorProfiles profile;

  const DoctorProfile({super.key, required this.profile});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start, // Ensure text is left-aligned
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
                          // Profile Image with Default Fallback
                          CircleAvatar(
                            radius: 80,
                            backgroundImage: widget.profile.pictueURl.isNotEmpty
                                ? NetworkImage(widget.profile.pictueURl)
                                : const AssetImage("assets/images/defaultProfile.webp") as ImageProvider,
                          ),
                          const SizedBox(width: 16),

                          // Profile Details
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Container for Experience
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppPallete.primaryColor, // Use your theme color
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${widget.profile.experience} years \nExperience",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Container for Focus
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppPallete.headings, // Use your theme color
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Focus: \n  random", // Replace with actual data
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
                "Profile", // Replace with actual data
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.primaryColor,
                ),
                textAlign: TextAlign.left, // Ensure text is left-aligned
              ),
              const SizedBox(height: 10),
              const Text(
                "RandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandom", // Replace with actual data
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: AppPallete.textColor,
                ),
                textAlign: TextAlign.left, // Ensure text is left-aligned
              ),
              const SizedBox(height: 20),
              const Text(
                "Career Paths", // Replace with actual data
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.primaryColor,
                ),
                textAlign: TextAlign.left, // Ensure text is left-aligned
              ),
              const SizedBox(height: 10),
              const Text(
                "RandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandom", // Replace with actual data
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: AppPallete.textColor,
                ),
                textAlign: TextAlign.left, // Ensure text is left-aligned
              ),
              const SizedBox(height: 20),
              const Text(
                "Highlights", // Replace with actual data
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.primaryColor,
                ),
                textAlign: TextAlign.left, // Ensure text is left-aligned
              ),
              const SizedBox(height: 10),
              const Text(
                "RandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandomRandom", // Replace with actual data
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: AppPallete.textColor,
                ),
                textAlign: TextAlign.left, // Ensure text is left-aligned
              ),
            ],
          ),
        ),
      ),
    );
  }
}
