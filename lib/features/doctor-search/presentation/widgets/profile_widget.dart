import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/doctor-search/data/model/doctor_list_model.dart';

class ProfileWidget extends StatelessWidget {
  final DoctorListModel profile;

  const ProfileWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: AppPallete.headings,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Ensure everything is centered vertically
          children: [
            // Profile Image with Default Fallback
            CircleAvatar(
              radius: 40,
              backgroundImage: const AssetImage("assets/images/defaultProfile.webp"), // Default Image
            ),
            const SizedBox(width: 16), // Add space between image and text

            // Profile Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Sign Up Button Aligned Properly
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${profile.firstName} ${profile.lastName}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis, // Prevent overflow
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/doctor-profile', extra: profile),
                        child: const Text(
                          'Learn More',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(profile.specialty),
                  Text(profile.email, style: const TextStyle(fontSize: 14, color: AppPallete.textColor)),
                  Text(profile.number, style: const TextStyle(fontSize: 16, color: AppPallete.textColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
