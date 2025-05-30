import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_app/core/themes/color_palette.dart';
import 'package:medical_app/features/patient/patient_dashboard/dashboard_db.dart';

class DoctorSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final DashboardDB dashboardDB;

  DoctorSearchDelegate({required this.dashboardDB});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: AppPallete.primaryColor),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: AppPallete.primaryColor),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: dashboardDB.searchDoctors(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return const Center(
            child: Text(
              'No doctors found',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final doctor = results[index];
            final fullName = '${doctor['title']} ${doctor['firstName']} ${doctor['lastName']}';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/doctor.jpg'),
                ),
                title: Text(
                  fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(doctor['specialty']),
                onTap: () {
                    final String? doctorId = doctor['id'] as String?; // Extract ID
                    if (doctorId != null && doctorId.isNotEmpty) {
                      // Navigate directly from here OR close with ID if the caller handles navigation
                      // Option A: Navigate directly
                      context.go('/patient/doctors/profile_view', extra: doctorId);

                      // Option B: Close with ID (if the page that called showSearch handles it)
                      // close(context, doctorId);
                    } else {
                      // Handle missing ID if necessary
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not get doctor ID.')),
                      );
                      close(context, null); // Close without selection
                    }
},
              ),
            );
          },
        );
      },
    );
  }
}