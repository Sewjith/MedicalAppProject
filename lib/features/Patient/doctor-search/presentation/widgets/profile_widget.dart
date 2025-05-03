import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/themes/color_palette.dart';

class ProfileWidget extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const ProfileWidget({super.key, required this.profileData});

  String _getProfileImageAsset(String? gender) {
    final lowerGender = gender?.toLowerCase();
    if (lowerGender == 'female') {
      return 'assets/images/female_doctor.jpg';
    } else {
      return 'assets/images/doctor.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract data safely
    final String doctorId = profileData['id']?.toString() ?? ''; // Ensure ID is extracted as String
    final String firstName = profileData['first_name'] ?? '';
    final String lastName = profileData['last_name'] ?? '';
    final String title = profileData['title'] ?? '';
    final String specialty = profileData['specialty'] ?? 'N/A';
    final String gender = profileData['gender'];
    final int experience = profileData['years_of_experience'] ?? 0;
    final String fullName = '$title $firstName $lastName'.trim();
    final String imageAssetPath = _getProfileImageAsset(gender);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.blue[50],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell( // Make the whole card tappable
         onTap: () {
            // --- Ensure only String ID is passed ---
            if (doctorId.isNotEmpty) {
               context.go('/patient/doctors/profile_view', extra: doctorId);
            } else {
                ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Doctor ID not found.')),
                );
             }
          },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage(imageAssetPath),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isEmpty ? 'Unknown Doctor' : fullName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppPallete.primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppPallete.textColor.withOpacity(0.8)
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (experience > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$experience Years Experience',
                         style: TextStyle(
                           fontSize: 13,
                           color: AppPallete.greyColor,
                         ),
                       ),
                    ]
                  ],
                ),
              ),
               const Icon(Icons.chevron_right, color: AppPallete.greyColor),
            ],
          ),
        ),
      ),
    );
  }
}